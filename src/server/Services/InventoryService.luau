--!strict
-- Owns all mutation of a player's item inventory. ShopService (and, in the
-- future, any other granting system) calls into this rather than touching
-- profile.Inventory directly, so stack-limit enforcement lives in one place.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)
local ItemConfig = require(ReplicatedStorage.Shared.Config.ItemConfig)

local DataService = require(script.Parent.DataService)

local InventoryService = {}

local function fireInventoryChanged(player: Player)
	local profile = DataService.GetProfile(player)
	if not profile then
		return
	end
	Remotes.GetEvent(NetConstants.InventoryChanged):FireClient(player, profile.Inventory)
end

function InventoryService.HasCapacity(player: Player, itemId: string, addAmount: number): boolean
	local profile = DataService.GetProfile(player)
	local item = ItemConfig.GetById(itemId)
	if not profile or not item then
		return false
	end

	local current = profile.Inventory[itemId] or 0
	return current + addAmount <= item.StackLimit
end

function InventoryService.AddItem(player: Player, itemId: string, amount: number): boolean
	local profile = DataService.GetProfile(player)
	local item = ItemConfig.GetById(itemId)
	if not profile or not item then
		return false
	end

	local current = profile.Inventory[itemId] or 0
	profile.Inventory[itemId] = math.min(current + amount, item.StackLimit)
	fireInventoryChanged(player)
	return true
end

function InventoryService.RemoveItem(player: Player, itemId: string, amount: number): boolean
	local profile = DataService.GetProfile(player)
	if not profile then
		return false
	end

	local current = profile.Inventory[itemId] or 0
	if current < amount then
		return false
	end

	local newAmount = current - amount
	profile.Inventory[itemId] = if newAmount <= 0 then nil else newAmount
	fireInventoryChanged(player)
	return true
end

function InventoryService.GetQuantity(player: Player, itemId: string): number
	local profile = DataService.GetProfile(player)
	if not profile then
		return 0
	end
	return profile.Inventory[itemId] or 0
end

function InventoryService.Init() end

return InventoryService

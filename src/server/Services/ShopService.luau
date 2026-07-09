--!strict
-- Soft-currency shop: validates a buy request against ItemConfig and the
-- player's actual coin balance/inventory capacity server-side — the client
-- only ever sends an item id, never a price or amount.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)
local ItemConfig = require(ReplicatedStorage.Shared.Config.ItemConfig)

local DataService = require(script.Parent.DataService)
local InventoryService = require(script.Parent.InventoryService)
local BuffService = require(script.Parent.BuffService)

-- Testing convenience only, not a real mechanic — see NetConstants.
local DEBUG_GRANT_AMOUNT = 100

local ShopService = {}

local function fireCurrencyChanged(player: Player)
	local profile = DataService.GetProfile(player)
	if not profile then
		return
	end
	Remotes.GetEvent(NetConstants.CurrencyChanged):FireClient(player, profile.Currency)
end

local function firePurchaseFailed(player: Player, reason: string)
	Remotes.GetEvent(NetConstants.PurchaseFailed):FireClient(player, { Reason = reason })
end

function ShopService.AddCoins(player: Player, amount: number)
	local profile = DataService.GetProfile(player)
	if not profile then
		return
	end
	profile.Currency.Coins += amount
	fireCurrencyChanged(player)
end

local function onRequestBuyItem(player: Player, itemId: any)
	if typeof(itemId) ~= "string" then
		return
	end
	if not DataService.IsLoaded(player) then
		return
	end

	local item = ItemConfig.GetById(itemId)
	if not item or not item.ShopPriceCoins then
		return
	end

	local profile = DataService.GetProfile(player)
	if not profile then
		return
	end

	if profile.Currency.Coins < item.ShopPriceCoins then
		firePurchaseFailed(player, "NotEnoughCoins")
		return
	end
	if not InventoryService.HasCapacity(player, itemId, 1) then
		firePurchaseFailed(player, "InventoryFull")
		return
	end

	profile.Currency.Coins -= item.ShopPriceCoins
	InventoryService.AddItem(player, itemId, 1)
	fireCurrencyChanged(player)
end

-- Testing convenience: grants a fixed coin amount (doubled while CoinX2 is
-- active, so this doubles as the visible proof that the buff works) so the
-- whole shop catalog can be exercised without a real Robux purchase.
local function onRequestDebugAddCoins(player: Player)
	if not DataService.IsLoaded(player) then
		return
	end
	local multiplier = BuffService.GetCoinMultiplier(player)
	ShopService.AddCoins(player, DEBUG_GRANT_AMOUNT * multiplier)
end

function ShopService.Init()
	Remotes.GetEvent(NetConstants.RequestBuyItem).OnServerEvent:Connect(onRequestBuyItem)
	Remotes.GetEvent(NetConstants.RequestDebugAddCoins).OnServerEvent:Connect(onRequestDebugAddCoins)
end

return ShopService

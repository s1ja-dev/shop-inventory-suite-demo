--!strict
-- Thin wrapper turning UI clicks into remote fires. Client never sends
-- amounts/prices — only the id of what it wants; the server decides
-- everything else.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)

local InputController = {}

function InputController.BuyItem(itemId: string)
	Remotes.GetEvent(NetConstants.RequestBuyItem):FireServer(itemId)
end

function InputController.PromptRobuxPurchase(productId: number)
	Remotes.GetEvent(NetConstants.RequestPromptRobuxPurchase):FireServer(productId)
end

function InputController.ToggleSetting(settingId: string)
	Remotes.GetEvent(NetConstants.RequestToggleSetting):FireServer(settingId)
end

function InputController.BuyBuff(buffId: string)
	Remotes.GetEvent(NetConstants.RequestBuyBuff):FireServer(buffId)
end

function InputController.DebugAddCoins()
	Remotes.GetEvent(NetConstants.RequestDebugAddCoins):FireServer()
end

return InputController

--!strict
-- Single source of truth for RemoteEvent/RemoteFunction instances. The
-- server creates them on boot; the client only ever looks them up (waits for
-- them to exist, never creates). No ad-hoc Instance.new("RemoteEvent")
-- anywhere else in the codebase.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetConstants = require(script.Parent.NetConstants)

type RemoteKind = "RemoteEvent" | "RemoteFunction"

local REMOTE_KINDS: { [string]: RemoteKind } = {
	[NetConstants.RequestProfile] = "RemoteFunction",
	[NetConstants.RequestBuyItem] = "RemoteEvent",
	[NetConstants.InventoryChanged] = "RemoteEvent",
	[NetConstants.CurrencyChanged] = "RemoteEvent",
	[NetConstants.RequestPromptRobuxPurchase] = "RemoteEvent",
	[NetConstants.RequestToggleSetting] = "RemoteEvent",
	[NetConstants.SettingsChanged] = "RemoteEvent",
	[NetConstants.RequestBuyBuff] = "RemoteEvent",
	[NetConstants.BuffChanged] = "RemoteEvent",
	[NetConstants.RequestDebugAddCoins] = "RemoteEvent",
}

local Remotes = {}

local folder: Folder? = nil

local function getFolder(): Folder
	if folder then
		return folder
	end

	if RunService:IsServer() then
		local newFolder = Instance.new("Folder")
		newFolder.Name = "Remotes"

		for name, kind in REMOTE_KINDS do
			local instance = Instance.new(kind)
			instance.Name = name
			instance.Parent = newFolder
		end

		newFolder.Parent = ReplicatedStorage
		folder = newFolder
		return newFolder
	end

	local existing = ReplicatedStorage:WaitForChild("Remotes") :: Folder
	folder = existing
	return existing
end

function Remotes.GetEvent(name: string): RemoteEvent
	return getFolder():WaitForChild(name) :: RemoteEvent
end

function Remotes.GetFunction(name: string): RemoteFunction
	return getFolder():WaitForChild(name) :: RemoteFunction
end

return Remotes

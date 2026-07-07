--!strict
-- Toggleable settings with data saving. The profile itself already
-- persists via DataService's normal save cycle — this service just owns
-- the mutation + broadcast.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)
local SettingsConfig = require(ReplicatedStorage.Shared.Config.SettingsConfig)

local DataService = require(script.Parent.DataService)

local SettingsService = {}

local function isKnownSetting(settingId: string): boolean
	for _, setting in SettingsConfig.GetAllInOrder() do
		if setting.Id == settingId then
			return true
		end
	end
	return false
end

local function onRequestToggleSetting(player: Player, settingId: any)
	if typeof(settingId) ~= "string" or not isKnownSetting(settingId) then
		return
	end
	if not DataService.IsLoaded(player) then
		return
	end

	local profile = DataService.GetProfile(player)
	if not profile then
		return
	end

	local current = profile.Settings[settingId]
	if current == nil then
		current = false
	end
	profile.Settings[settingId] = not current

	Remotes.GetEvent(NetConstants.SettingsChanged):FireClient(player, profile.Settings)
end

function SettingsService.Init()
	Remotes.GetEvent(NetConstants.RequestToggleSetting).OnServerEvent:Connect(onRequestToggleSetting)
end

return SettingsService

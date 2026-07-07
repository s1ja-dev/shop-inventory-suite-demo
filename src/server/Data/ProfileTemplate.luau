--!strict
-- Default shape for a brand-new player profile.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsConfig = require(ReplicatedStorage.Shared.Config.SettingsConfig)
local Types = require(ReplicatedStorage.Shared.Types.Types)
type PlayerProfile = Types.PlayerProfile

local ProfileTemplate = {}

function ProfileTemplate.New(): PlayerProfile
	return {
		Currency = { Coins = 100 },
		Inventory = {},
		Settings = SettingsConfig.GetDefaults(),
		Monetization = { GrantedPurchaseIds = {} },
	}
end

return ProfileTemplate

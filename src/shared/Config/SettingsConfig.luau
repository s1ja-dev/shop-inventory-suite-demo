--!strict
-- Toggleable player settings — small, explicitly-requested part of the
-- "shop/inventory/settings" bundle real freelance posts ask for.

export type SettingDefinition = {
	Id: string,
	DisplayName: string,
	Default: boolean,
}

local SettingsConfig = {}

local SETTINGS: { SettingDefinition } = {
	{ Id = "MusicEnabled", DisplayName = "Music", Default = true },
	{ Id = "SfxEnabled", DisplayName = "Sound Effects", Default = true },
	{ Id = "ReducedMotion", DisplayName = "Reduced Motion", Default = false },
}

function SettingsConfig.GetAllInOrder(): { SettingDefinition }
	return SETTINGS
end

function SettingsConfig.GetDefaults(): { [string]: boolean }
	local defaults = {}
	for _, setting in SETTINGS do
		defaults[setting.Id] = setting.Default
	end
	return defaults
end

return SettingsConfig

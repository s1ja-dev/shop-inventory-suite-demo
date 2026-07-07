--!strict
-- Timed "active buff" catalog: consumable purchases that apply a temporary
-- effect (movement stat or coin multiplier) for a fixed duration instead of
-- sitting in inventory. Server owns all effect application (BuffService) —
-- this module is data only, no Color3/visual fields (Theme is client-only,
-- shared config shouldn't depend on it).

export type BuffId = "SpeedBoost" | "JumpBoost" | "CoinX2"

export type BuffDefinition = {
	Id: BuffId,
	Name: string,
	Description: string,
	ShortLabel: string,
	PriceCoins: number,
	Duration: number, -- seconds
	Multiplier: number, -- WalkSpeed/JumpPower multiplier; CoinX2 uses this as its coin multiplier
}

local BUFFS: { [string]: BuffDefinition } = {
	SpeedBoost = {
		Id = "SpeedBoost",
		Name = "Speed Boost",
		Description = "+50% WalkSpeed",
		ShortLabel = "SPD",
		PriceCoins = 30,
		Duration = 30,
		Multiplier = 1.5,
	},
	JumpBoost = {
		Id = "JumpBoost",
		Name = "Jump Boost",
		Description = "+50% Jump Power",
		ShortLabel = "JUMP",
		PriceCoins = 30,
		Duration = 30,
		Multiplier = 1.5,
	},
	CoinX2 = {
		Id = "CoinX2",
		Name = "Coin x2",
		Description = "Double coins from the debug grant",
		ShortLabel = "x2",
		PriceCoins = 50,
		Duration = 30,
		Multiplier = 2,
	},
}

local ORDER = { "SpeedBoost", "JumpBoost", "CoinX2" }

local ActiveBuffConfig = {}

function ActiveBuffConfig.Get(buffId: string): BuffDefinition?
	return BUFFS[buffId]
end

function ActiveBuffConfig.GetAllInOrder(): { BuffDefinition }
	local result = {}
	for _, id in ORDER do
		table.insert(result, BUFFS[id])
	end
	return result
end

return ActiveBuffConfig

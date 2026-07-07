--!strict
-- Item catalog: every purchasable/ownable item in one place. Rarity drives
-- the accent color used across Shop/Inventory UI (Theme colors, not per-item
-- hardcoded colors) so the palette stays centrally retunable.

export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic"

export type ItemDefinition = {
	Id: string,
	Name: string,
	Rarity: Rarity,
	StackLimit: number,
	ShopPriceCoins: number?, -- nil = not directly buyable in the shop
}

local ItemConfig = {}

local ITEMS: { [string]: ItemDefinition } = {
	wooden_sword = {
		Id = "wooden_sword",
		Name = "Wooden Sword",
		Rarity = "Common",
		StackLimit = 1,
		ShopPriceCoins = 50,
	},
	iron_shield = {
		Id = "iron_shield",
		Name = "Iron Shield",
		Rarity = "Uncommon",
		StackLimit = 1,
		ShopPriceCoins = 150,
	},
	speed_potion = {
		Id = "speed_potion",
		Name = "Speed Potion",
		Rarity = "Rare",
		StackLimit = 99,
		ShopPriceCoins = 40,
	},
	golden_crown = {
		Id = "golden_crown",
		Name = "Golden Crown",
		Rarity = "Epic",
		StackLimit = 1,
		ShopPriceCoins = 500,
	},
}

local ORDER = { "wooden_sword", "iron_shield", "speed_potion", "golden_crown" }

function ItemConfig.GetById(itemId: string): ItemDefinition?
	return ITEMS[itemId]
end

function ItemConfig.GetShopItemsInOrder(): { ItemDefinition }
	local result = {}
	for _, id in ORDER do
		table.insert(result, ITEMS[id])
	end
	return result
end

return ItemConfig

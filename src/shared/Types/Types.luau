--!strict
-- Shared type aliases for the player profile shape.

export type PlayerProfile = {
	Currency: {
		Coins: number,
	},
	Inventory: {
		[string]: number, -- ItemId -> quantity owned
	},
	Settings: {
		[string]: boolean,
	},
	Monetization: {
		GrantedPurchaseIds: { [string]: boolean },
	},
}

return {}

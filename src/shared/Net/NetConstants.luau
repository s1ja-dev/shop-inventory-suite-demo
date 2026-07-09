--!strict
-- String identifiers for every remote. Kept separate from Remotes.luau so
-- both server and client can reference names without pulling in the
-- Instance-creation logic.

local NetConstants = {
	-- RemoteFunction: client actively pulls its current snapshot once its own
	-- scripts are ready, instead of the server pushing on PlayerAdded — a
	-- push can race ahead of the client connecting its listener (especially
	-- with no DataStore latency in local testing), silently leaving the HUD
	-- stuck on default values.
	RequestProfile = "RequestProfile",

	RequestBuyItem = "RequestBuyItem",
	InventoryChanged = "InventoryChanged",
	CurrencyChanged = "CurrencyChanged",

	-- Fired instead of silently no-op'ing whenever a buy request (item or
	-- buff) fails a server-side check, so the client can show a toast instead
	-- of leaving the player guessing why nothing happened.
	PurchaseFailed = "PurchaseFailed",

	RequestPromptRobuxPurchase = "RequestPromptRobuxPurchase",

	RequestToggleSetting = "RequestToggleSetting",
	SettingsChanged = "SettingsChanged",

	RequestBuyBuff = "RequestBuyBuff",
	BuffChanged = "BuffChanged",

	-- Testing convenience only — grants a fixed amount of coins so the shop
	-- can be exercised without a real Robux purchase. Not a real mechanic;
	-- keep it server-decided (no payload) like everything else here.
	RequestDebugAddCoins = "RequestDebugAddCoins",
}

return NetConstants

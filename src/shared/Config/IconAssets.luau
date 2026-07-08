--!strict
-- Icon image ids for shop/inventory/settings UI. Uploaded via the Roblox
-- Open Cloud Assets API (2026-07-08) from Vector_UI_Pack_dobo_ui and
-- Game-Icon-Pack-v1.4-PNG. Every consumer only sets an Image if the id is
-- non-empty, so an empty string here would just fall back to the current
-- text/color placeholder.
--
-- NOTE: uploading with assetType="Decal" returns a Decal *wrapper* asset id
-- — that id does NOT work directly as an ImageLabel.Image source. The ids
-- below are already the resolved wrapper.Texture ids (see
-- combat-system-demo/src/shared/Config/IconAssets.luau for the full
-- writeup of why, and roblox-open-cloud-api-key memory for the reusable
-- resolution steps via game:GetObjects).
local IconAssets = {
	-- Vector_UI_Pack_dobo_ui/Icons/256px/coin_icon_256px.png (wrapper 136538238627499)
	Coin = "rbxassetid://88826208591815",
	-- Vector_UI_Pack_dobo_ui/Icons/256px/shop_icon_256px.png (wrapper 121669585265233)
	Shop = "rbxassetid://71221561093887",
	-- Game-Icon-Pack-v1.4-PNG/no-padding/256px/white/2-items/backpack.png (wrapper 99862122617796)
	Inventory = "rbxassetid://113294270445255",
	-- Vector_UI_Pack_dobo_ui/Icons/256px/settings_icon_256px.png (wrapper 140165066922385)
	Settings = "rbxassetid://117189072895685",
	-- Vector_UI_Pack_dobo_ui/Icons/256px/sword_icon_256px.png (wrapper 97927832664612)
	Sword = "rbxassetid://138157929985277",
	-- Game-Icon-Pack-v1.4-PNG/no-padding/256px/white/3-gear/shield.png (wrapper 107894816561978)
	Shield = "rbxassetid://78964602021501",
	-- Game-Icon-Pack-v1.4-PNG/no-padding/256px/white/5-food/potion.png (wrapper 100075195533388)
	Potion = "rbxassetid://114993793602622",
	-- Game-Icon-Pack-v1.4-PNG/no-padding/256px/white/3-gear/crown.png (wrapper 88707317030185)
	Crown = "rbxassetid://132354276412823",
	-- Vector_UI_Pack_dobo_ui/Icons/256px/gem_icon_256px.png (wrapper 72189137174044)
	Gem = "rbxassetid://131471189511693",
	-- Vector_UI_Pack_dobo_ui/Icons/256px/energy_icon_256px.png (wrapper 80366864134911)
	Speed = "rbxassetid://93701680383936",
	-- Game-Icon-Pack-v1.4-PNG/no-padding/256px/white/8-ui/arrow-up.png (wrapper 74864444592058)
	Jump = "rbxassetid://103332812055344",
	-- Vector_UI_Pack_dobo_ui/Icons/256px/coins_icon_256px.png (wrapper 123544080425772)
	CoinX2 = "rbxassetid://103152327083117",
	-- Vector_UI_Pack_dobo_ui/Icons/256px/tickV2_icon_256px.png (wrapper 138045089777514)
	ToggleOn = "rbxassetid://120526855121925",
	-- Vector_UI_Pack_dobo_ui/Icons/256px/close_icon_256px.png (wrapper 128839148390962)
	ToggleOff = "rbxassetid://85886293483776",
}

return IconAssets

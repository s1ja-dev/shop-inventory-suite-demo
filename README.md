# Shop / Inventory / Settings Suite Demo

A server-authoritative shop, inventory, settings, timed-buff, and monetization suite for Roblox, built in Luau with [Rojo](https://rojo.space/). Part of a Roblox scripting portfolio.

## What it demonstrates

- **Server-authoritative purchases** — the client only ever sends an item/buff/setting **id**, never a price or amount. The server validates coin balance, stack limits, and buff cost/duration before granting anything.
- **DataStore persistence** — `DataService` wraps DataStoreService with pcall+retry loading, staggered autosave, and save-on-`BindToClose`. Degrades gracefully to "no persistence" when API access is off (local testing) instead of crashing the server.
- **Robux monetization** — `MarketplaceService.ProcessReceipt` with idempotent granting (records each `PurchaseId` in the profile to defeat Roblox's known double-grant-on-retry bug).
- **Timed active buffs** — Speed Boost / Jump Boost / Coin×2, applied from fixed base values (never compounding on re-purchase — re-buying just refreshes the timer), with pop-in countdown badges.
- **Settings** — toggle options with data saving.
- **Race-free client bootstrap** — the client pulls its initial state via a `RequestProfile` RemoteFunction once its own scripts are ready, instead of the server push-racing ahead of the client's listeners.

## Structure

```
src/shared/    Classes, Net, Config (Item/Product/Settings/ActiveBuff), Types
src/server/    DataService, InventoryService, ShopService, BuffService, MonetizationService, SettingsService
src/client/    StateController + InputController, HUD, Shop / Inventory / Settings panels, BuffTimerUI
```

See [`UI_REQUIREMENTS.md`](UI_REQUIREMENTS.md) for the full remote/data contract — visuals can be reskinned without touching game logic.

## Running

Needs an empty Roblox Studio place with the Rojo plugin connected:

```
rojo serve
```

A "+100 Coins" button is included as a testing convenience so the whole catalog can be exercised without a real Robux purchase. Enable *Studio Access to API Services* in Game Settings to test real DataStore saving.

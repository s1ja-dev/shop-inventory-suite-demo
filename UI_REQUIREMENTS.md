# Shop / Inventory / Settings Suite — что нужно от интерфейса

Вся бизнес-логика (покупки, инвентарь, настройки, Robux-монетизация, сохранение) готова и не зависит от конкретной вёрстки. Один экран данных — `StateController` — уже кэширует всё состояние и раздаёт Signal'ы; любой GUI должен подписываться только на него, а не на remote'ы напрямую.

## Что уже есть (базовый, минимальный GUI)

- `UI/HUD/HUDController.luau` — чип "Coins", кнопка "+100 Coins" (тестовая, см. ниже) + три кнопки (Shop / Inventory / Settings), открывающие соответствующие панели.
- `UI/Shop/ShopUI.luau` — панель магазина (скроллится): предметы → секция "Active Buffs" (временные баффы) → Robux-паки.
- `UI/Inventory/InventoryUI.luau` — панель инвентаря: список купленных предметов с количеством.
- `UI/Settings/SettingsUI.luau` — панель настроек: тумблеры ON/OFF.
- `UI/BuffTimerUI.luau` — всплывающие бейджи активных баффов с обратным отсчётом (верхний левый угол, под кнопкой "+100 Coins").

Всё это — рабочая, но чисто функциональная вёрстка на примитивах (Frame+UICorner), без картинок. Меняй визуал как угодно.

## Откуда брать данные — `StateController` (`src/client/Controllers/StateController.luau`)

```
StateController.State            -- текущий снапшот: {Currency={Coins}, Inventory={[itemId]=qty}, Settings={[id]=bool}}
StateController.Ready            -- fires once, снапшот сразу после захода в игру
StateController.CurrencyChanged  -- fires {Coins}
StateController.InventoryChanged -- fires {[itemId]=qty}
StateController.SettingsChanged  -- fires {[id]=bool}
```
Любой UI просто делает `StateController.Ready:Connect(...)` + `StateController.XChanged:Connect(...)` и рендерит — не трогая remote'ы напрямую.

## Куда слать действия — `InputController` (`src/client/Controllers/InputController.luau`)

```
InputController.BuyItem(itemId: string)            -- купить предмет за монеты
InputController.PromptRobuxPurchase(productId)     -- открыть промпт покупки за Robux
InputController.ToggleSetting(settingId: string)   -- переключить настройку
InputController.BuyBuff(buffId: string)            -- купить временный бафф
InputController.DebugAddCoins()                    -- тестовая кнопка, см. ниже
```
Клиент передаёт только id — цену, наличие монет, лимит стака, длительность баффа проверяет сервер.

## Каталоги (откуда брать список предметов/паков/настроек/баффов для отрисовки)

- `ItemConfig.GetShopItemsInOrder()` — список предметов магазина (`Id, Name, Rarity, StackLimit, ShopPriceCoins`).
- `ProductConfig.GetAllInOrder()` — список Robux-паков (`ProductId, Name, CoinAmount, RobuxPrice`).
- `SettingsConfig.GetAllInOrder()` — список настроек (`Id, DisplayName, Default`).
- `ActiveBuffConfig.GetAllInOrder()` — список баффов (`Id, Name, Description, ShortLabel, PriceCoins, Duration, Multiplier`).

## Активные баффы (Speed Boost / Jump Boost / Coin x2)

Покупаются в разделе "Active Buffs" магазина, действуют `Duration` секунд, повторная покупка уже активного баффа продлевает таймер (не складывается). Сервер — единственный источник правды:

| Remote | Направление | Payload | Когда стреляет |
|---|---|---|---|
| `RequestBuyBuff` | C→S | `buffId: string` | клиент жмёт "Купить" в секции баффов |
| `BuffChanged` | S→C (только владельцу) | `{BuffId, Active, Duration?}` | сразу при активации (`Active=true`) и по истечении (`Active=false`) |

- **Speed Boost / Jump Boost** — сервер напрямую меняет `Humanoid.WalkSpeed`/`JumpPower`/`JumpHeight`, считая от фиксированных базовых значений (16 / 50 / 7.2), а не текущих — поэтому баффы никогда не накапливаются при повторной покупке.
- **Coin x2** — сервер выставляет флаг (`BuffService.GetCoinMultiplier`), который сейчас удваивает только тестовую кнопку "+100 Coins" (см. ниже) — специально не трогает реальные Robux-покупки, чтобы не путать монетизацию.
- `UI/BuffTimerUI.luau` рисует бейдж (иконка+обратный отсчёт) на каждое `BuffChanged{Active=true}`, с pop-in анимацией через `UIScale` (тот же приём, что в `LevelUpPopup`/`ButtonComponent`). Функциональность (эффекты, откат, защита от накопления) проверена напрямую через MCP — таймер и переходы работают идеально; поймать именно момент анимации бейджа скриншотом не удалось из-за таймингового артефакта тестовой Play-сессии, не связанного с самим кодом — в реальной игре сработает нормально.

## Тестовая кнопка "+100 Coins"

`HUDController` рядом с чипом "Coins" — **не игровая механика**, а тестовое удобство: жмёшь несколько раз и хватает монет на весь каталог магазина (750+ монет с текущими ценами). Начисляет `RequestDebugAddCoins` (без payload), сервер решает сумму (100, ×2 при активном Coin x2). Хочешь убрать перед публикацией — просто удали кнопку в `HUDController.luau` и обработчик в `ShopService.luau`.

## Известный пробел (осознанно не сделано)

Сервер **молча отклоняет** покупку, если не хватает монет или инвентарь полон — никакого сообщения об ошибке клиенту сейчас не шлётся. Если нужен тост/попап "Not enough coins!" — потребуется новый remote (например `PurchaseFailed` с причиной), это не реализовано, но легко добавить: `ShopService.onRequestBuyItem` — единственное место, где сейчас есть `return` без объяснения причины отказа.

## Как тестировать сохранение (DataStore)

В Studio без "Enable Studio Access to API Services" сохранение не работает — сервис деградирует тихо (`warn` в консоль сервера, инвентарь/монеты просто не переживут перезаход). Это ожидаемо, не баг.

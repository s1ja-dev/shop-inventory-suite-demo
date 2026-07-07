--!strict
-- Top-level HUD: coin readout + buttons to open Shop/Inventory/Settings
-- panels. Subscribes to StateController only for server-authoritative
-- state — never touches remotes directly.

local ClientRoot = script.Parent.Parent.Parent
local Theme = require(ClientRoot.Theme)
local StateController = require(ClientRoot.Controllers.StateController)
local InputController = require(ClientRoot.Controllers.InputController)
local ButtonComponent = require(ClientRoot.Components.ButtonComponent)
local CurrencyLabel = require(script.Parent.CurrencyLabel)

local HUDController = {}

local function formatNumber(value: number): string
	return tostring(math.floor(value))
end

function HUDController.Init(screenGui: ScreenGui, onOpenShop: () -> (), onOpenInventory: () -> (), onOpenSettings: () -> ())
	local root = Instance.new("Frame")
	root.Name = "HUD"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.Parent = screenGui

	local _, coinsValueLabel = CurrencyLabel.new({
		Caption = "Coins",
		AccentColor = Theme.Warning,
		Position = UDim2.fromOffset(16, 16),
		Parent = root,
	})

	-- Testing convenience only (see NetConstants.RequestDebugAddCoins) — not
	-- a real mechanic, just enough currency to exercise the whole shop
	-- without a real Robux purchase.
	local _, debugAddClicked = ButtonComponent.new({
		Text = "+100 Coins",
		Size = UDim2.fromOffset(180, 36),
		Position = UDim2.fromOffset(16, 72),
		BackgroundColor = Theme.Success,
		Parent = root,
	})
	debugAddClicked:Connect(InputController.DebugAddCoins)

	local actions = Instance.new("Frame")
	actions.Name = "Actions"
	actions.Size = UDim2.fromOffset(400, 56)
	actions.AnchorPoint = Vector2.new(1, 1)
	actions.Position = UDim2.new(1, -16, 1, -16)
	actions.BackgroundTransparency = 1
	actions.Parent = root

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.Parent = actions

	local shopButton, shopClicked = ButtonComponent.new({
		Text = "Shop",
		Size = UDim2.fromOffset(120, 48),
		BackgroundColor = Theme.Shop,
		LayoutOrder = 1,
		Parent = actions,
	})
	shopClicked:Connect(onOpenShop)

	local inventoryButton, inventoryClicked = ButtonComponent.new({
		Text = "Inventory",
		Size = UDim2.fromOffset(120, 48),
		BackgroundColor = Theme.Premium,
		LayoutOrder = 2,
		Parent = actions,
	})
	inventoryClicked:Connect(onOpenInventory)

	local settingsButton, settingsClicked = ButtonComponent.new({
		Text = "Settings",
		Size = UDim2.fromOffset(120, 48),
		BackgroundColor = Theme.Info,
		LayoutOrder = 3,
		Parent = actions,
	})
	settingsClicked:Connect(onOpenSettings)

	local function refreshCurrency(data: { Coins: number })
		coinsValueLabel.Text = formatNumber(data.Coins)
	end

	StateController.Ready:Connect(function(state: StateController.Snapshot)
		refreshCurrency(state.Currency)
	end)
	StateController.CurrencyChanged:Connect(refreshCurrency)

	local currentState = StateController.State
	if currentState then
		refreshCurrency(currentState.Currency)
	end
end

return HUDController

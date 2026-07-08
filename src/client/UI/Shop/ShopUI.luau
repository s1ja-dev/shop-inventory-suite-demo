--!strict
-- Shop panel: soft-currency item rows (accent-colored by rarity), a
-- timed active-buff section, and a Robux coin-pack section — scrolls since
-- all three sections together don't fit a fixed-height panel. Buttons only
-- ever send an id — price/amount/duration are resolved server-side.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConfig = require(ReplicatedStorage.Shared.Config.ItemConfig)
local ProductConfig = require(ReplicatedStorage.Shared.Config.ProductConfig)
local ActiveBuffConfig = require(ReplicatedStorage.Shared.Config.ActiveBuffConfig)
local IconAssets = require(ReplicatedStorage.Shared.Config.IconAssets)

local ClientRoot = script.Parent.Parent.Parent
local Theme = require(ClientRoot.Theme)
local InputController = require(ClientRoot.Controllers.InputController)
local ButtonComponent = require(ClientRoot.Components.ButtonComponent)
local PanelComponent = require(ClientRoot.Components.PanelComponent)

local RARITY_COLORS: { [string]: Color3 } = {
	Common = Theme.TextMuted,
	Uncommon = Theme.Success,
	Rare = Theme.Info,
	Epic = Theme.Premium,
}

local BUFF_COLORS: { [string]: Color3 } = {
	SpeedBoost = Theme.Success,
	JumpBoost = Theme.Info,
	CoinX2 = Theme.Warning,
}

local BUFF_ICONS: { [string]: string } = {
	SpeedBoost = IconAssets.Speed,
	JumpBoost = IconAssets.Jump,
	CoinX2 = IconAssets.CoinX2,
}

local ITEM_ICONS: { [string]: string } = {
	wooden_sword = IconAssets.Sword,
	iron_shield = IconAssets.Shield,
	speed_potion = IconAssets.Potion,
	golden_crown = IconAssets.Crown,
}

local ShopUI = {}

local function sectionHeader(text: string, layoutOrder: number, parent: Instance): TextLabel
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 28)
	header.BackgroundTransparency = 1
	header.Text = text
	header.TextColor3 = Theme.TextMuted
	header.Font = Enum.Font.GothamBold
	header.TextScaled = true
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.LayoutOrder = layoutOrder
	header.Parent = parent
	return header
end

local function buyRow(options: {
	Text: string,
	ButtonText: string,
	IconId: string?,
	AccentColor: Color3,
	LayoutOrder: number,
	Parent: Instance,
	OnBuy: () -> (),
})
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 48)
	row.BackgroundColor3 = Theme.ChipBackground
	row.BorderSizePixel = 0
	row.LayoutOrder = options.LayoutOrder
	row.Parent = options.Parent

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row

	local rowStroke = Instance.new("UIStroke")
	rowStroke.Thickness = 2
	rowStroke.Color = options.AccentColor
	rowStroke.Parent = row

	-- Only added once an icon has actually been uploaded (see IconAssets) —
	-- leaves the plain text-only row as the fallback.
	local hasIcon = options.IconId ~= nil and options.IconId ~= ""
	if hasIcon then
		local icon = Instance.new("ImageLabel")
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.Position = UDim2.new(0, 10, 0.5, 0)
		icon.Size = UDim2.fromOffset(28, 28)
		icon.BackgroundTransparency = 1
		icon.Image = options.IconId :: string
		icon.Parent = row
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.55, if hasIcon then -38 else 0, 1, 0)
	label.Position = UDim2.fromOffset(if hasIcon then 48 else 10, 0)
	label.BackgroundTransparency = 1
	label.Text = options.Text
	label.TextColor3 = Theme.TextLight
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local _, buyClicked = ButtonComponent.new({
		Text = options.ButtonText,
		Size = UDim2.fromOffset(150, 36),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundColor = options.AccentColor,
		Parent = row,
	})
	buyClicked:Connect(options.OnBuy)
end

function ShopUI.Init(screenGui: ScreenGui): Frame
	local panel, body = PanelComponent.new({
		Title = "Shop",
		Size = UDim2.fromOffset(420, 480),
		Position = UDim2.fromScale(0.5, 0.5),
		AccentColor = Theme.Shop,
		Parent = screenGui,
	})

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = body

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = scroll

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.Parent = scroll

	for index, item in ItemConfig.GetShopItemsInOrder() do
		buyRow({
			Text = `{item.Name} ({item.Rarity})`,
			ButtonText = `{item.ShopPriceCoins} Coins`,
			IconId = ITEM_ICONS[item.Id],
			AccentColor = RARITY_COLORS[item.Rarity] or Theme.Info,
			LayoutOrder = index,
			Parent = scroll,
			OnBuy = function()
				InputController.BuyItem(item.Id)
			end,
		})
	end

	sectionHeader("Active Buffs", 50, scroll)

	for index, buff in ActiveBuffConfig.GetAllInOrder() do
		buyRow({
			Text = `{buff.Name} ({buff.Description})`,
			ButtonText = `{buff.PriceCoins} Coins`,
			IconId = BUFF_ICONS[buff.Id],
			AccentColor = BUFF_COLORS[buff.Id] or Theme.Info,
			LayoutOrder = 50 + index,
			Parent = scroll,
			OnBuy = function()
				InputController.BuyBuff(buff.Id)
			end,
		})
	end

	sectionHeader("Coin Packs (Robux)", 100, scroll)

	for index, product in ProductConfig.GetAllInOrder() do
		buyRow({
			Text = `{product.Name} (+{product.CoinAmount})`,
			ButtonText = `{product.RobuxPrice} R$`,
			IconId = IconAssets.Gem,
			AccentColor = Theme.Premium,
			LayoutOrder = 100 + index,
			Parent = scroll,
			OnBuy = function()
				InputController.PromptRobuxPurchase(product.ProductId)
			end,
		})
	end

	return panel
end

return ShopUI

--!strict
-- Inventory panel: lists owned items with quantity, accent-colored by
-- rarity. Rebuilds its rows whenever StateController reports a change —
-- simple and correct for the small item counts a demo needs; a real game
-- with hundreds of item types would want an incremental diff instead.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConfig = require(ReplicatedStorage.Shared.Config.ItemConfig)

local ClientRoot = script.Parent.Parent.Parent
local Theme = require(ClientRoot.Theme)
local StateController = require(ClientRoot.Controllers.StateController)
local PanelComponent = require(ClientRoot.Components.PanelComponent)

local RARITY_COLORS: { [string]: Color3 } = {
	Common = Theme.TextMuted,
	Uncommon = Theme.Success,
	Rare = Theme.Info,
	Epic = Theme.Premium,
}

local InventoryUI = {}

function InventoryUI.Init(screenGui: ScreenGui): Frame
	local panel, body = PanelComponent.new({
		Title = "Inventory",
		Size = UDim2.fromOffset(380, 420),
		AccentColor = Theme.Premium,
		Parent = screenGui,
	})

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = body

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = body

	local emptyLabel = Instance.new("TextLabel")
	emptyLabel.Size = UDim2.new(1, 0, 0, 32)
	emptyLabel.BackgroundTransparency = 1
	emptyLabel.Text = "No items yet — visit the Shop!"
	emptyLabel.TextColor3 = Theme.TextMuted
	emptyLabel.Font = Enum.Font.GothamBold
	emptyLabel.TextScaled = true
	emptyLabel.Parent = body

	local function rebuild(inventory: { [string]: number })
		for _, child in body:GetChildren() do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		local hasAny = false
		local order = 0
		for itemId, quantity in inventory do
			if quantity <= 0 then
				continue
			end
			hasAny = true
			order += 1

			local item = ItemConfig.GetById(itemId)
			local displayName = if item then item.Name else itemId
			local rarity = if item then item.Rarity else "Common"

			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 44)
			row.BackgroundColor3 = Theme.ChipBackground
			row.BorderSizePixel = 0
			row.LayoutOrder = order
			row.Parent = body

			local rowCorner = Instance.new("UICorner")
			rowCorner.CornerRadius = UDim.new(0, 8)
			rowCorner.Parent = row

			local rowStroke = Instance.new("UIStroke")
			rowStroke.Thickness = 2
			rowStroke.Color = RARITY_COLORS[rarity] or Theme.Info
			rowStroke.Parent = row

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -70, 1, 0)
			label.Position = UDim2.fromOffset(10, 0)
			label.BackgroundTransparency = 1
			label.Text = displayName
			label.TextColor3 = Theme.TextLight
			label.Font = Enum.Font.GothamBold
			label.TextScaled = true
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = row

			local quantityLabel = Instance.new("TextLabel")
			quantityLabel.Size = UDim2.fromOffset(50, 44)
			quantityLabel.AnchorPoint = Vector2.new(1, 0.5)
			quantityLabel.Position = UDim2.new(1, -8, 0.5, 0)
			quantityLabel.BackgroundTransparency = 1
			quantityLabel.Text = `x{quantity}`
			quantityLabel.TextColor3 = RARITY_COLORS[rarity] or Theme.Info
			quantityLabel.Font = Enum.Font.GothamBlack
			quantityLabel.TextScaled = true
			quantityLabel.Parent = row
		end

		emptyLabel.Visible = not hasAny
	end

	StateController.Ready:Connect(function(state: StateController.Snapshot)
		rebuild(state.Inventory)
	end)
	StateController.InventoryChanged:Connect(rebuild)

	local currentState = StateController.State
	if currentState then
		rebuild(currentState.Inventory)
	end

	return panel
end

return InventoryUI

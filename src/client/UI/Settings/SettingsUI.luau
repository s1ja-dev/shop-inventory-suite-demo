--!strict
-- Settings panel: one toggle row per SettingsConfig entry. Built from plain
-- ButtonComponent instances styled as ON/OFF pills (no external toggle
-- image assets needed) — flips color/text from server-confirmed state, not
-- optimistically, so a rejected toggle never shows a wrong state.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsConfig = require(ReplicatedStorage.Shared.Config.SettingsConfig)

local ClientRoot = script.Parent.Parent.Parent
local Theme = require(ClientRoot.Theme)
local StateController = require(ClientRoot.Controllers.StateController)
local InputController = require(ClientRoot.Controllers.InputController)
local ButtonComponent = require(ClientRoot.Components.ButtonComponent)
local PanelComponent = require(ClientRoot.Components.PanelComponent)

local SettingsUI = {}

function SettingsUI.Init(screenGui: ScreenGui): Frame
	local panel, body = PanelComponent.new({
		Title = "Settings",
		Size = UDim2.fromOffset(360, 260),
		AccentColor = Theme.Info,
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

	local toggleButtons: { [string]: TextButton } = {}

	local function applyState(settingId: string, enabled: boolean)
		local button = toggleButtons[settingId]
		if not button then
			return
		end
		button.Text = if enabled then "ON" else "OFF"
		button.BackgroundColor3 = if enabled then Theme.Success else Theme.ChipBackground
	end

	for index, setting in SettingsConfig.GetAllInOrder() do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 44)
		row.BackgroundColor3 = Theme.ChipBackground
		row.BorderSizePixel = 0
		row.LayoutOrder = index
		row.Parent = body

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 8)
		rowCorner.Parent = row

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -90, 1, 0)
		label.Position = UDim2.fromOffset(10, 0)
		label.BackgroundTransparency = 1
		label.Text = setting.DisplayName
		label.TextColor3 = Theme.TextLight
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = row

		local toggleButton, toggleClicked = ButtonComponent.new({
			Text = if setting.Default then "ON" else "OFF",
			Size = UDim2.fromOffset(70, 32),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			BackgroundColor = if setting.Default then Theme.Success else Theme.ChipBackground,
			Parent = row,
		})
		toggleButtons[setting.Id] = toggleButton

		toggleClicked:Connect(function()
			InputController.ToggleSetting(setting.Id)
		end)
	end

	local function refreshAll(settings: { [string]: boolean })
		for settingId, enabled in settings do
			applyState(settingId, enabled)
		end
	end

	StateController.Ready:Connect(function(state: StateController.Snapshot)
		refreshAll(state.Settings)
	end)
	StateController.SettingsChanged:Connect(refreshAll)

	local currentState = StateController.State
	if currentState then
		refreshAll(currentState.Settings)
	end

	return panel
end

return SettingsUI

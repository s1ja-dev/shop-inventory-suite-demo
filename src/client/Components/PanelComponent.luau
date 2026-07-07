--!strict
-- Reusable modal panel: rounded+stroked outer Frame that clips descendants
-- (so a colored header bar reads as having only its top corners rounded),
-- a title, and a close button pre-wired to hide the panel. Callers parent
-- their own content into the returned `body` Frame below the header.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Classes.Signal)
local Theme = require(script.Parent.Parent.Theme)
local ButtonComponent = require(script.Parent.ButtonComponent)

export type PanelOptions = {
	Title: string,
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	AccentColor: Color3?,
	Parent: Instance?,
}

local HEADER_HEIGHT = 44

local PanelComponent = {}

function PanelComponent.new(options: PanelOptions): (Frame, Frame, Signal.Signal)
	local panel = Instance.new("Frame")
	panel.Name = options.Title .. "Panel"
	panel.Size = options.Size or UDim2.fromOffset(320, 240)
	panel.Position = options.Position or UDim2.fromScale(0.5, 0.5)
	panel.AnchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Theme.PanelBackground
	panel.BorderSizePixel = 0
	panel.ClipsDescendants = true
	panel.Visible = false

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Theme.PanelStroke
	stroke.Parent = panel

	local accent = options.AccentColor or Theme.Info

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
	header.BackgroundColor3 = accent
	header.BorderSizePixel = 0
	header.ZIndex = 2
	header.Parent = panel

	local headerGradient = Instance.new("UIGradient")
	headerGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), accent)
	headerGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.65),
		NumberSequenceKeypoint.new(1, 1),
	})
	headerGradient.Rotation = 90
	headerGradient.Parent = header

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -54, 1, 0)
	title.Position = UDim2.fromOffset(14, 0)
	title.BackgroundTransparency = 1
	title.Text = options.Title
	title.TextColor3 = Theme.TextLight
	title.TextStrokeColor3 = Color3.new(0, 0, 0)
	title.TextStrokeTransparency = 0.4
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 2
	title.Parent = header

	local closeButton, closeClicked = ButtonComponent.new({
		Text = "X",
		Size = UDim2.fromOffset(28, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundColor = Theme.Danger,
		CornerRadius = UDim.new(0.5, 0),
		Parent = header,
	})
	closeButton.ZIndex = 2

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT)
	body.Position = UDim2.fromOffset(0, HEADER_HEIGHT)
	body.BackgroundTransparency = 1
	body.Parent = panel

	local closed = Signal.new()
	closeClicked:Connect(function()
		panel.Visible = false
		closed:Fire()
	end)

	if options.Parent then
		panel.Parent = options.Parent
	end

	return panel, body, closed
end

return PanelComponent

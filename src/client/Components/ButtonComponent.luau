--!strict
-- Generic styled button factory — the one reusable UI atom shared across
-- every demo in this portfolio. "Chunky candy" style: rounded corners, a
-- darker-shade outline of the fill color, bold outlined text, and a
-- hover-grow/click-shrink animation. The scale animation uses a UIScale
-- child (not the button's own Size) specifically so a button sitting inside
-- a UIListLayout doesn't reflow its siblings every time it's hovered.
-- Returns the Instance plus a Signal fired on MouseButton1Click;
-- presentation only, callers own any request-debounce.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Classes.Signal)
local Theme = require(script.Parent.Parent.Theme)

export type ButtonOptions = {
	Text: string,
	IconId: string?,
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor: Color3?,
	TextColor: Color3?,
	CornerRadius: UDim?,
	LayoutOrder: number?,
	Parent: Instance?,
}

local HOVER_SCALE = 1.05
local CLICK_SCALE = 0.92
local BASE_STROKE_THICKNESS = 3
local HOVER_STROKE_THICKNESS = 4.5
local TWEEN_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local ButtonComponent = {}

function ButtonComponent.new(options: ButtonOptions): (TextButton, Signal.Signal, ImageLabel?)
	local fillColor = options.BackgroundColor or Theme.Info

	local button = Instance.new("TextButton")
	button.Name = "Button"
	-- Text lives on a separate child TextLabel (below), not this Text
	-- property — UIPadding reliably insets child GuiObjects but does NOT
	-- constrain a TextButton's own native Text rendering, confirmed live:
	-- with an icon present, native centered text drew straight through it
	-- instead of respecting the extra left padding.
	button.Text = ""
	button.Size = options.Size or UDim2.fromOffset(160, 44)
	button.Position = options.Position or UDim2.fromScale(0, 0)
	button.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	button.BackgroundColor3 = fillColor
	button.AutoButtonColor = false
	button.BorderSizePixel = 0

	if options.LayoutOrder then
		button.LayoutOrder = options.LayoutOrder
	end

	local corner = Instance.new("UICorner")
	corner.CornerRadius = options.CornerRadius or UDim.new(0, 10)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = BASE_STROKE_THICKNESS
	stroke.Color = Theme.Darken(fillColor, 0.55)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = button

	-- Only added once an icon has actually been uploaded — leaves the
	-- plain text-only button as the fallback. No UIPadding here on purpose:
	-- it insets EVERY child equally, including the icon itself, which
	-- pushed the icon to the right until it landed on top of the text
	-- instead of before it — confirmed live. Explicit offsets for both
	-- icon and text avoid that entirely.
	local icon: ImageLabel? = nil
	local hasIcon = options.IconId ~= nil and options.IconId ~= ""
	if hasIcon then
		local iconLabel = Instance.new("ImageLabel")
		iconLabel.Name = "Icon"
		iconLabel.AnchorPoint = Vector2.new(0, 0.5)
		iconLabel.Position = UDim2.new(0, 8, 0.5, 0)
		iconLabel.Size = UDim2.fromOffset(20, 20)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Image = options.IconId :: string
		iconLabel.ZIndex = 2
		iconLabel.Parent = button
		icon = iconLabel
	end

	local textLeftInset = if hasIcon then 34 else 10
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Position = UDim2.fromOffset(textLeftInset, 0)
	textLabel.Size = UDim2.new(1, -(textLeftInset + 10), 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = options.Text
	textLabel.TextColor3 = options.TextColor or Theme.TextLight
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.TextScaled = true
	textLabel.Parent = button

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = button

	if options.Parent then
		button.Parent = options.Parent
	end

	local function tweenScaleTo(target: number)
		TweenService:Create(scale, TWEEN_INFO, { Scale = target }):Play()
	end

	local function tweenStrokeTo(thickness: number)
		TweenService:Create(stroke, TWEEN_INFO, { Thickness = thickness }):Play()
	end

	button.MouseEnter:Connect(function()
		tweenScaleTo(HOVER_SCALE)
		tweenStrokeTo(HOVER_STROKE_THICKNESS)
	end)
	button.MouseLeave:Connect(function()
		tweenScaleTo(1)
		tweenStrokeTo(BASE_STROKE_THICKNESS)
	end)
	button.MouseButton1Down:Connect(function()
		tweenScaleTo(CLICK_SCALE)
	end)
	button.MouseButton1Up:Connect(function()
		tweenScaleTo(HOVER_SCALE)
	end)

	local clicked = Signal.new()
	button.MouseButton1Click:Connect(function()
		clicked:Fire()
	end)

	return button, clicked, icon
end

return ButtonComponent

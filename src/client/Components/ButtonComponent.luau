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

function ButtonComponent.new(options: ButtonOptions): (TextButton, Signal.Signal)
	local fillColor = options.BackgroundColor or Theme.Info

	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Text = options.Text
	button.Size = options.Size or UDim2.fromOffset(160, 44)
	button.Position = options.Position or UDim2.fromScale(0, 0)
	button.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
	button.BackgroundColor3 = fillColor
	button.TextColor3 = options.TextColor or Theme.TextLight
	button.TextStrokeColor3 = Color3.new(0, 0, 0)
	button.TextStrokeTransparency = 0.5
	button.Font = Enum.Font.GothamBlack
	button.TextScaled = true
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

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = button

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

	return button, clicked
end

return ButtonComponent

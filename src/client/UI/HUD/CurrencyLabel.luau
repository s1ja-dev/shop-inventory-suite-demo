--!strict
-- Small reusable stat-chip: a caption + a value TextLabel the caller
-- updates directly. "Chunky candy" style: rounded dark chip, colored accent
-- stroke, bold outlined value text.

local Theme = require(script.Parent.Parent.Parent.Theme)

export type CurrencyLabelOptions = {
	Caption: string,
	AccentColor: Color3?,
	Size: UDim2?,
	LayoutOrder: number?,
	Parent: Instance?,
}

local CurrencyLabel = {}

function CurrencyLabel.new(options: CurrencyLabelOptions): (Frame, TextLabel)
	local accent = options.AccentColor or Theme.Info

	local frame = Instance.new("Frame")
	frame.Name = options.Caption .. "Tile"
	frame.Size = options.Size or UDim2.fromOffset(180, 48)
	frame.BackgroundColor3 = Theme.ChipBackground
	frame.BorderSizePixel = 0

	if options.LayoutOrder then
		frame.LayoutOrder = options.LayoutOrder
	end

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = accent
	stroke.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = frame

	local caption = Instance.new("TextLabel")
	caption.Name = "Caption"
	caption.Size = UDim2.new(1, 0, 0.38, 0)
	caption.BackgroundTransparency = 1
	caption.Text = string.upper(options.Caption)
	caption.TextColor3 = Theme.TextMuted
	caption.Font = Enum.Font.GothamBold
	caption.TextScaled = true
	caption.TextXAlignment = Enum.TextXAlignment.Left
	caption.Parent = frame

	local value = Instance.new("TextLabel")
	value.Name = "Value"
	value.Size = UDim2.new(1, 0, 0.62, 0)
	value.Position = UDim2.fromScale(0, 0.38)
	value.BackgroundTransparency = 1
	value.Text = "0"
	value.TextColor3 = accent
	value.TextStrokeColor3 = Color3.new(0, 0, 0)
	value.TextStrokeTransparency = 0.5
	value.Font = Enum.Font.GothamBlack
	value.TextScaled = true
	value.TextXAlignment = Enum.TextXAlignment.Left
	value.Parent = frame

	if options.Parent then
		frame.Parent = options.Parent
	end

	return frame, value
end

return CurrencyLabel

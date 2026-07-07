--!strict
-- Shared color palette for the "chunky candy" UI style (thick outlines,
-- saturated gradient buttons, bold outlined fonts) — kept visually consistent
-- across every demo in this portfolio. One place to retune the whole game's
-- look.

local Theme = {
	Success = Color3.fromRGB(76, 209, 105),
	Info = Color3.fromRGB(66, 150, 240),
	Premium = Color3.fromRGB(178, 102, 255),
	Warning = Color3.fromRGB(255, 175, 64),
	Danger = Color3.fromRGB(235, 70, 70),
	Shop = Color3.fromRGB(64, 130, 220),

	PanelBackground = Color3.fromRGB(255, 255, 255),
	PanelStroke = Color3.fromRGB(20, 20, 25),
	ChipBackground = Color3.fromRGB(35, 38, 48),
	TextDark = Color3.fromRGB(35, 35, 40),
	TextLight = Color3.fromRGB(255, 255, 255),
	TextMuted = Color3.fromRGB(175, 178, 190),
}

-- Darkens a color for outlines, mirroring the "stroke = darker shade of
-- fill" relationship seen in reference UI kits.
function Theme.Darken(color: Color3, factor: number): Color3
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, math.min(s * 1.1, 1), v * factor)
end

return Theme

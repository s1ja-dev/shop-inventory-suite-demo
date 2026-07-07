--!strict
-- Pop-in badges showing active timed buffs with a live countdown. Purely a
-- render of what BuffChanged already told us — the client never decides
-- whether a buff is active or for how long, it just displays server state
-- and counts down locally between updates.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)
local ActiveBuffConfig = require(ReplicatedStorage.Shared.Config.ActiveBuffConfig)

local ClientRoot = script.Parent.Parent
local Theme = require(ClientRoot.Theme)

local BUFF_COLORS: { [string]: Color3 } = {
	SpeedBoost = Theme.Success,
	JumpBoost = Theme.Info,
	CoinX2 = Theme.Warning,
}

type BuffChangedData = {
	BuffId: string,
	Active: boolean,
	Duration: number?,
}

local BuffTimerUI = {}

function BuffTimerUI.Init(screenGui: ScreenGui)
	local container = Instance.new("Frame")
	container.Name = "BuffTimers"
	container.Position = UDim2.fromOffset(16, 120)
	container.Size = UDim2.fromOffset(300, 70)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 8)
	layout.Parent = container

	local badges: { [string]: Frame } = {}

	local function removeBadge(buffId: string)
		local badge = badges[buffId]
		if not badge then
			return
		end
		badges[buffId] = nil

		local tween = TweenService:Create(badge, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
		tween:Play()
		task.delay(0.2, function()
			badge:Destroy()
		end)
	end

	local function createBadge(buffId: string, shortLabel: string, color: Color3, duration: number, layoutOrder: number)
		if badges[buffId] then
			badges[buffId]:Destroy()
			badges[buffId] = nil
		end

		local badge = Instance.new("Frame")
		badge.Name = buffId
		badge.Size = UDim2.fromOffset(64, 64)
		badge.BackgroundColor3 = color
		badge.BorderSizePixel = 0
		badge.LayoutOrder = layoutOrder
		badge.Parent = container
		badges[buffId] = badge

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = badge

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 3
		stroke.Color = Theme.Darken(color, 0.55)
		stroke.Parent = badge

		local scale = Instance.new("UIScale")
		scale.Scale = 0
		scale.Parent = badge
		TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
			:Play()

		local labelText = Instance.new("TextLabel")
		labelText.Size = UDim2.new(1, 0, 0.5, 0)
		labelText.BackgroundTransparency = 1
		labelText.Text = shortLabel
		labelText.TextColor3 = Theme.TextLight
		labelText.TextStrokeColor3 = Color3.new(0, 0, 0)
		labelText.TextStrokeTransparency = 0.4
		labelText.Font = Enum.Font.GothamBlack
		labelText.TextScaled = true
		labelText.Parent = badge

		local countdownText = Instance.new("TextLabel")
		countdownText.Size = UDim2.new(1, 0, 0.5, 0)
		countdownText.Position = UDim2.fromScale(0, 0.5)
		countdownText.BackgroundTransparency = 1
		countdownText.Text = tostring(math.ceil(duration))
		countdownText.TextColor3 = Theme.TextLight
		countdownText.TextStrokeColor3 = Color3.new(0, 0, 0)
		countdownText.TextStrokeTransparency = 0.4
		countdownText.Font = Enum.Font.GothamBold
		countdownText.TextScaled = true
		countdownText.Parent = badge

		task.spawn(function()
			local remaining = duration
			while remaining > 0 and badges[buffId] == badge do
				task.wait(1)
				remaining -= 1
				if badges[buffId] == badge then
					countdownText.Text = tostring(math.max(math.ceil(remaining), 0))
				end
			end
		end)
	end

	local buffChanged = Remotes.GetEvent(NetConstants.BuffChanged)
	buffChanged.OnClientEvent:Connect(function(data: BuffChangedData)
		local buff = ActiveBuffConfig.Get(data.BuffId)
		if not buff then
			return
		end

		if data.Active and data.Duration then
			createBadge(data.BuffId, buff.ShortLabel, BUFF_COLORS[data.BuffId] or Theme.Info, data.Duration, 1)
		else
			removeBadge(data.BuffId)
		end
	end)
end

return BuffTimerUI

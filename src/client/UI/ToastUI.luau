--!strict
-- Short-lived error toasts for purchase failures the server rejected
-- (PurchaseFailed) — purely a render of a reason code the server already
-- decided, same one-directional pattern as every other UI module here.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)

local ClientRoot = script.Parent.Parent
local Theme = require(ClientRoot.Theme)

local REASON_TEXT: { [string]: string } = {
	NotEnoughCoins = "Not enough coins!",
	InventoryFull = "Inventory full!",
}

local VISIBLE_DURATION = 1.6
local TWEEN_IN = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_OUT = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

type PurchaseFailedData = {
	Reason: string,
}

local ToastUI = {}

function ToastUI.Init(screenGui: ScreenGui)
	local container = Instance.new("Frame")
	container.Name = "Toasts"
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.Position = UDim2.new(0.5, 0, 0, 100)
	container.Size = UDim2.fromOffset(280, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 6)
	layout.Parent = container

	local function showToast(text: string)
		local toast = Instance.new("TextLabel")
		toast.Size = UDim2.new(1, 0, 0, 40)
		toast.BackgroundColor3 = Theme.Danger
		toast.BorderSizePixel = 0
		toast.Text = text
		toast.TextColor3 = Theme.TextLight
		toast.TextStrokeColor3 = Color3.new(0, 0, 0)
		toast.TextStrokeTransparency = 0.4
		toast.Font = Enum.Font.GothamBlack
		toast.TextScaled = true
		toast.BackgroundTransparency = 1
		toast.TextTransparency = 1
		toast.Parent = container

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = toast

		local scale = Instance.new("UIScale")
		scale.Scale = 0.85
		scale.Parent = toast

		TweenService:Create(toast, TWEEN_IN, { BackgroundTransparency = 0.1, TextTransparency = 0 }):Play()
		TweenService:Create(scale, TWEEN_IN, { Scale = 1 }):Play()

		task.delay(VISIBLE_DURATION, function()
			TweenService:Create(toast, TWEEN_OUT, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
			task.delay(TWEEN_OUT.Time, function()
				toast:Destroy()
			end)
		end)
	end

	local purchaseFailed = Remotes.GetEvent(NetConstants.PurchaseFailed)
	purchaseFailed.OnClientEvent:Connect(function(data: PurchaseFailedData)
		showToast(REASON_TEXT[data.Reason] or "Purchase failed.")
	end)
end

return ToastUI

--!strict
local Players = game:GetService("Players")

local StateController = require(script.Parent.Controllers.StateController)
local HUDController = require(script.Parent.UI.HUD.HUDController)
local ShopUI = require(script.Parent.UI.Shop.ShopUI)
local InventoryUI = require(script.Parent.UI.Inventory.InventoryUI)
local SettingsUI = require(script.Parent.UI.Settings.SettingsUI)
local BuffTimerUI = require(script.Parent.UI.BuffTimerUI)

local ClientMain = {}

local function togglePanel(panel: Frame, others: { Frame })
	local opening = not panel.Visible
	for _, other in others do
		other.Visible = false
	end
	panel.Visible = opening
end

function ClientMain.Start()
	StateController.Init()

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopInventoryUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local shopPanel = ShopUI.Init(screenGui)
	local inventoryPanel = InventoryUI.Init(screenGui)
	local settingsPanel = SettingsUI.Init(screenGui)
	BuffTimerUI.Init(screenGui)

	HUDController.Init(screenGui, function()
		togglePanel(shopPanel, { inventoryPanel, settingsPanel })
	end, function()
		togglePanel(inventoryPanel, { shopPanel, settingsPanel })
	end, function()
		togglePanel(settingsPanel, { shopPanel, inventoryPanel })
	end)
end

return ClientMain

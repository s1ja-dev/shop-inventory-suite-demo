--!strict
-- Orchestrates service initialization order and the shared Remotes-folder
-- bootstrap. This is the only module that knows about every service.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)

local DataService = require(script.Parent.Services.DataService)
local InventoryService = require(script.Parent.Services.InventoryService)
local BuffService = require(script.Parent.Services.BuffService)
local ShopService = require(script.Parent.Services.ShopService)
local MonetizationService = require(script.Parent.Services.MonetizationService)
local SettingsService = require(script.Parent.Services.SettingsService)

local ServerMain = {}

function ServerMain.Start()
	Remotes.GetFunction(NetConstants.RequestProfile)

	DataService.Init()
	InventoryService.Init()
	BuffService.Init()
	ShopService.Init()
	MonetizationService.Init()
	SettingsService.Init()
end

return ServerMain

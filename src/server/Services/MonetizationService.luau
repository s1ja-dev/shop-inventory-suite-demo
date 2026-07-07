--!strict
-- MarketplaceService.ProcessReceipt with idempotent purchase granting
-- (records PurchaseId in the profile to guard against Roblox's known
-- double-grant-on-retry issue). Copied near-verbatim from the Backrooms
-- project's MonetizationService — this pattern is genre-agnostic.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)
local ProductConfig = require(ReplicatedStorage.Shared.Config.ProductConfig)

local DataService = require(script.Parent.DataService)
local ShopService = require(script.Parent.ShopService)

type ReceiptInfo = {
	PlayerId: number,
	PurchaseId: string,
	ProductId: number,
	CurrencySpent: number,
	CurrencyType: Enum.CurrencyType,
	PlaceIdWherePurchased: number,
}

local MonetizationService = {}

local function processReceipt(receiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- Player has left; rely on Roblox's automatic retry (up to 3 days).
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if not DataService.IsLoaded(player) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = DataService.GetProfile(player)
	if not profile then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if profile.Monetization.GrantedPurchaseIds[receiptInfo.PurchaseId] then
		-- Already granted in a previous call; acknowledging again is safe
		-- (idempotent) and protects against Roblox's double-grant retries.
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local product = ProductConfig.GetByProductId(receiptInfo.ProductId)
	if not product then
		warn(`MonetizationService: unknown ProductId {receiptInfo.ProductId} in receipt {receiptInfo.PurchaseId}`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local ok = pcall(function()
		ShopService.AddCoins(player, product.CoinAmount)
	end)
	if not ok then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	profile.Monetization.GrantedPurchaseIds[receiptInfo.PurchaseId] = true
	DataService.ForceSave(player)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Client asks the server to prompt a purchase rather than calling
-- MarketplaceService:PromptProductPurchase directly, so the productId gets
-- validated against ProductConfig before Roblox's purchase UI ever opens.
local function onRequestPromptRobuxPurchase(player: Player, productId: any)
	if typeof(productId) ~= "number" then
		return
	end

	if not ProductConfig.GetByProductId(productId) then
		return
	end

	MarketplaceService:PromptProductPurchase(player, productId)
end

function MonetizationService.Init()
	MarketplaceService.ProcessReceipt = processReceipt

	Remotes.GetEvent(NetConstants.RequestPromptRobuxPurchase).OnServerEvent:Connect(onRequestPromptRobuxPurchase)
end

return MonetizationService

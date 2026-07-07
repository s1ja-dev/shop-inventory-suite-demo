--!strict
-- Dev-product catalog for Robux-purchased coin bundles. ProductId values are
-- placeholders — real IDs get created in the Creator Dashboard once this
-- place is published, same convention as the Backrooms project. Placeholders
-- use distinct negative numbers (real Roblox product IDs are always
-- positive) so they can never collide with each other or be mistaken for a
-- real ID — three products sharing the same placeholder previously made
-- `GetByProductId` resolve all three to whichever came first.
export type ProductDefinition = {
	ProductId: number,
	Name: string,
	CoinAmount: number,
	RobuxPrice: number,
}

local ProductConfig = {}

local PRODUCTS: { ProductDefinition } = {
	{ ProductId = -1, Name = "Small Coin Pack", CoinAmount = 100, RobuxPrice = 25 },
	{ ProductId = -2, Name = "Medium Coin Pack", CoinAmount = 550, RobuxPrice = 100 },
	{ ProductId = -3, Name = "Large Coin Pack", CoinAmount = 1200, RobuxPrice = 200 },
}

function ProductConfig.GetByProductId(productId: number): ProductDefinition?
	for _, product in PRODUCTS do
		if product.ProductId == productId then
			return product
		end
	end
	return nil
end

function ProductConfig.GetAllInOrder(): { ProductDefinition }
	return PRODUCTS
end

return ProductConfig

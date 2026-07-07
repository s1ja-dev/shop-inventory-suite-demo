--!strict
-- Single client-side cache of server-pushed state + Signals for UI to
-- subscribe to. UI modules never touch remotes directly — everything flows
-- through here. Remotes -> StateController -> UI (render-only) is the one
-- direction data moves on the client.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)
local Signal = require(ReplicatedStorage.Shared.Classes.Signal)

export type Snapshot = {
	Currency: { Coins: number },
	Inventory: { [string]: number },
	Settings: { [string]: boolean },
}

local StateController = {}

StateController.State = nil :: Snapshot?

StateController.Ready = Signal.new()
StateController.CurrencyChanged = Signal.new()
StateController.InventoryChanged = Signal.new()
StateController.SettingsChanged = Signal.new()

function StateController.Init()
	-- Connect delta listeners before pulling the initial snapshot, so a
	-- change that lands between the pull and its response is never missed.
	Remotes.GetEvent(NetConstants.CurrencyChanged).OnClientEvent:Connect(function(data: { Coins: number })
		local state = StateController.State
		if state then
			state.Currency = data
		end
		StateController.CurrencyChanged:Fire(data)
	end)

	Remotes.GetEvent(NetConstants.InventoryChanged).OnClientEvent:Connect(function(data: { [string]: number })
		local state = StateController.State
		if state then
			state.Inventory = data
		end
		StateController.InventoryChanged:Fire(data)
	end)

	Remotes.GetEvent(NetConstants.SettingsChanged).OnClientEvent:Connect(function(data: { [string]: boolean })
		local state = StateController.State
		if state then
			state.Settings = data
		end
		StateController.SettingsChanged:Fire(data)
	end)

	-- InvokeServer yields, so pull the snapshot on its own thread rather than
	-- blocking the rest of ClientMain.Start() (UI builds immediately and
	-- fills in via Ready/the delta signals above whenever this resolves).
	task.spawn(function()
		local snapshot = Remotes.GetFunction(NetConstants.RequestProfile):InvokeServer()
		if snapshot then
			StateController.State = snapshot
			StateController.Ready:Fire(snapshot)
		end
	end)
end

return StateController

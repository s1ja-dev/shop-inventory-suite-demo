--!strict
-- Minimal custom event. Thin wrapper over BindableEvent so modules can expose
-- a `Signal` on their public API instead of leaking RemoteEvents/BindableEvents
-- directly. No Wally in this project, so this intentionally avoids a
-- hand-rolled coroutine-pooling implementation in favor of something short
-- and obviously correct.

local Signal = {}
Signal.__index = Signal

export type Signal = typeof(setmetatable(
	{} :: {
		_bindable: BindableEvent,
	},
	Signal
))

function Signal.new(): Signal
	local self = setmetatable({}, Signal)
	self._bindable = Instance.new("BindableEvent")
	return self
end

function Signal.Connect(self: Signal, callback: (...any) -> ()): RBXScriptConnection
	return self._bindable.Event:Connect(callback)
end

function Signal.Once(self: Signal, callback: (...any) -> ()): RBXScriptConnection
	local connection: RBXScriptConnection
	connection = self._bindable.Event:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)
	return connection
end

function Signal.Wait(self: Signal): ...any
	return self._bindable.Event:Wait()
end

function Signal.Fire(self: Signal, ...: any)
	self._bindable:Fire(...)
end

function Signal.Destroy(self: Signal)
	self._bindable:Destroy()
end

return Signal

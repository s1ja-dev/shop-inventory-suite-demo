--!strict
-- Minimal cleanup ("janitor") utility: tracks connections/instances/callbacks
-- and disposes all of them together via :Destroy(). Used by any service or
-- controller that needs to tear down per-player, per-round, or per-entity
-- state without hand-listing every connection at the call site.

local Trove = {}
Trove.__index = Trove

export type Trove = typeof(setmetatable(
	{} :: {
		_items: { any },
	},
	Trove
))

local function cleanupItem(item: any)
	local itemType = typeof(item)
	if itemType == "RBXScriptConnection" then
		(item :: RBXScriptConnection):Disconnect()
	elseif itemType == "Instance" then
		(item :: Instance):Destroy()
	elseif itemType == "function" then
		(item :: () -> ())()
	elseif itemType == "thread" then
		task.cancel(item :: thread)
	elseif itemType == "table" and typeof((item :: any).Destroy) == "function" then
		(item :: { Destroy: (any) -> () }):Destroy()
	end
end

function Trove.new(): Trove
	local self = setmetatable({}, Trove)
	self._items = {}
	return self
end

function Trove.Add<T>(self: Trove, item: T): T
	table.insert(self._items, item)
	return item
end

function Trove.Clean(self: Trove)
	for index = #self._items, 1, -1 do
		local item = self._items[index]
		self._items[index] = nil
		cleanupItem(item)
	end
end

function Trove.Destroy(self: Trove)
	self:Clean()
end

return Trove

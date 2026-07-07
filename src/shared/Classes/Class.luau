--!strict
-- Minimal OOP base-class helper. No inheritance chains, no metatables magic
-- beyond __index wiring — every "class" module in this codebase follows the
-- same shape: `local MyClass = Class.new("MyClass")`, then define
-- `MyClass.new(...)` returning `setmetatable({}, MyClass)`.

local Class = {}

function Class.new(name: string)
	local class = {}
	class.__index = class
	class.ClassName = name
	return class
end

return Class

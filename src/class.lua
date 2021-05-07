-- Create a new object
local function object(class, ...)
	local parent = getmetatable(class).__index
	local object = setmetatable((parent and parent(...)) or {}, class)
	if class.__create then object:__create(...) end
	return object
end

local function index(t, key) return getmetatable(t)[key] end

-- Create a new class
function class(parent)
	-- Test to see if parent is likely a class
	if parent and type((getmetatable(parent) or {}).__call) ~= "function" then
		error("parent argument not a class")
	end

	-- Setup the new class
	return setmetatable(
		{__index = index, __call = (parent or {}).__call},
		{__index = parent, __call = object}
	)
end

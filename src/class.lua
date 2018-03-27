local function object(self, ...)
	local parent = getmetatable(self).__index
	local object = setmetatable((parent and parent(...)) or {}, self)
	-- Run the create function
	if self.create then object:create(...) end
	-- Return the object
	return object
end

local function index(t, key) return getmetatable(t)[key] end

-- Create a new class
function class(parent, ...)
	-- Test to see if parent can create an object
	if parent and not ((getmetatable(parent) or {}).__call and parent(...)) then
		error("parent argument not a class")
	end

	-- Setup the new class
	return setmetatable(
		{__index = index, __call = (parent or {}).__call},
		{__index = parent, __call = object}
	)
end


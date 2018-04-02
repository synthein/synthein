local enabledFunctions = require("gamestates/enabledFunctions")

local function emptyFunction() end

local function index(t, key)
	return getmetatable(t)[key] or (enabledFunctions[key] and emptyFunction)
end

local function call(self)
	return setmetatable({}, self)
end

local GameState = setmetatable({__index = index}, {__call = call})

return GameState

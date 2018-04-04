local enabledFunctions = require("gamestates/enabledFunctions")

local function index(t, key) return getmetatable(t)[key] end

local function call(self) return setmetatable({}, self) end

local GameState = setmetatable(
	{__index = index},
	{__index = enabledFunctions, __call = call}
)

return GameState

require("class")
local StackManager = require("stackManager")
local enabledFunctions = require("gamestates/enabledFunctions")
local MainMenu = require("gamestates/mainMenu")

local state

function love.load()
	state = StackManager.create(MainMenu, "stackQueue")

	local function getStateFunction(t, key)
		if enabledFunctions[key] then
			return state[key]
		end
	end

	setmetatable(love, {__index = getStateFunction})

	for i, flag in ipairs(arg) do
		if flag == "--debug" then
			debugmode = true
		end
		if flag == "--test" then
			require("tests")
			love.event.quit()
		end
	end
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
	if key == "f12" then debugmode = not debugmode end

	state.keypressed(key)
end

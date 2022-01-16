require("class")
local StackManager = require("stackManager")
local enabledFunctions = require("gamestates/enabledFunctions")
local MainMenu = require("gamestates/mainMenu")

local state

local usage =
[[usage: synthein [FLAGS]

Available flags:
    --test          Run the test suite.
    --scene=NAME    Bypass all menus and jump straight into a scene
    --help          Print this usage message.]]

function love.load()
	state = StackManager.create(MainMenu, "stackQueue")

	local function getStateFunction(_, key)
		if enabledFunctions[key] then
			return state[key]
		end
	end

	setmetatable(love, {__index = getStateFunction})

	local i = 1
	while arg[i] do
		if arg[i] == "--test" then
			require("tests")
			love.event.quit()
		elseif arg[i] == "--scene" then
			local InitWorld = require("gamestates/initWorld")
			local scene = arg[i+1]
			MainMenu.stackQueue:push(InitWorld).load(scene, {}, false)
			i = i + 1
		elseif arg[i]:match("^--scene=(%g+)") then
			local InitWorld = require("gamestates/initWorld")
			local scene = arg[i]:match("^--scene=(%g+)")
			MainMenu.stackQueue:push(InitWorld).load(scene, {}, false)
		elseif arg[i] == "--help" then
			print(usage)
			love.event.quit()
		end

		i = i + 1
	end
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end

	state.keypressed(key)
end

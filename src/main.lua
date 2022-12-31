require("class")
local StackManager = require("stackManager")
local enabledFunctions = require("gamestates/enabledFunctions")
local MainMenu = require("gamestates/mainMenu")
local log = require("log")

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
		elseif arg[i]:match("^--scene") then
			local scene = nil
			if arg[i] == "--scene" then
				scene = arg[i+1]
				i = i + 1
			else
				scene = arg[i]:match("^--scene=(%g+)")
			end

			if scene then
				local InitWorld = require("gamestates/initWorld")
				--TODO {{false, false}, {false, false}} is a bandaid. Perminant solution required
				-- No longer crashes with drones/players of team 1,2
				-- Still crashes with drones/players of teams 3+
				MainMenu.stackQueue:push(InitWorld).load(scene, {{false, false}, {false, false}}, false)
			else
				error(
					"--scene must have an argument. You provided these arguments: "
					.. table.concat(arg, " "))
			end
		elseif arg[i] == "--extern" then
			local sonic = require("sonic")
			log:info("%s", sonic)
			log:info("%s", sonic.hello())
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

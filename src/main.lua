require("class")
local MainMenu = require("gamestates/mainMenu")
local Settings = require("settings")
local StackManager = require("stackManager")
local console = require("console")
local enabledFunctions = require("gamestates/enabledFunctions")
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
		if arg[i] == "--unit-tests" then
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
				local fileName = string.format(Settings.scenesDir .. scene .. ".txt")

				local InGame = require("gamestates/inGame")
				MainMenu.stackQueue:push(InGame).load(love.filesystem.lines(fileName), {}, false)
			else
				error(
					"--scene must have an argument. You provided these arguments: "
					.. table.concat(arg, " "))
			end
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

function love.quit()
	console.quit()
end

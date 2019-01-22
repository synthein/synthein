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

	for _, flag in ipairs(arg) do
		if flag == "--test" then
			require("tests")
			love.event.quit()
		elseif flag:match("^--scene=(%w+)") then
			local InitWorld = require("gamestates/initWorld")
			local scene = flag:match("^--scene=(%w+)")
			MainMenu.stackQueue:push(InitWorld).load(scene, {}, false)
		elseif flag == "--help" then
			print(usage)
			love.event.quit()
		end
	end
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end

	state.keypressed(key)
end

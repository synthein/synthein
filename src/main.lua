require("class")
local Settings = require("settings")
local Controls = require("controls")
local console = require("console")
local log = require("log")

local gameStates = {
	MainMenu = require("gamestates/mainMenu"),
	InGame = require("gamestates/inGame"),
	NewGameMenu = require("gamestates/newGameMenu"),
	LoadGameMenu = require("gamestates/loadGameMenu"),
	ShipEditor = require("gamestates/shipEditor"),
	FormationEditor = require("gamestates/formationEditor"),
}

local state

function setGameState(newState, args)
	if type(newState) ~= "string" then
		error("NewState is a " .. type(newState) .. " type not a string type.")
	end
	state = gameStates[newState]
	if not state then
		error("Trying to switch to non existent game state: " .. newState)
	end
	if args then 
		state.load(unpack(args))
	end
end

local usage =
[[usage: synthein [FLAGS]

Available flags:
	--test          Run the test suite.
	--scene=NAME    Bypass all menus and jump straight into a scene
	--debug         Enable debug logs
	--help          Print this usage message.]]

function love.load()
	setGameState("MainMenu")
	
	Controls.loadDefaultMap()

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

				setGameState(
					"InGame",
					{love.filesystem.lines(fileName), {}, false})
			else
				error(
					"--scene must have an argument. You provided these arguments: "
					.. table.concat(arg, " "))
			end
		elseif arg[i] == "--debug" then
			Settings.debug = true
		elseif arg[i] == "--help" then
			print(usage)
			love.event.quit()
		end

		i = i + 1
	end
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end

	local control = Controls.lookupKey(key)
	state.pressed(control)
end

function love.keyreleased()
	local control = Controls.lookupKey(key)
	state.released(control)
end

function love.mousepressed(x, y, button)
	local control = Controls.lookupMouseButton(button)
	state.cursorpressed({x = x, y = y}, control)
end

function love.mousereleased(x, y, button)
	local control = Controls.lookupMouseButton(button)
	state.cursorreleased(cursor, control)
end

function love.mousemoved(x, y)
	local control = Controls.lookupMouseCursor()
	state.mousemoved({x = x, y = y}, control)
end

function love.wheelmoved(x, y)
	local control = Controls.lookupMouseWheel()
	state.wheelmoved({x, y}, control)
end

function love.gamepadpressed(joystick, button)
	--TODO Controls Map then pipe to state.pressed(control)

	state.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
	--TODO Controls Map then pipe to state.released(control)

	state.gamepadreleased(joystick, button)
end

function love.joystickpressed(joystick, button)
	local control = Controls.lookupJoystickButton(joystick, button)
	state.pressed(control)

	state.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	local control = Controls.lookupJoystickButton(joystick, button)
	state.released(control)

	state.joystickreleased(joystick, button)
end

function love.textinput(key)
	state.textinput(key)
end

function love.update(dt)
	--TODO Axis control inputs
	--TODO Compouned cursors
	--TODO ???? Controls.lookupJoystickAxis(joystick, axis)
	
	state.update(dt)
end

function love.resize(w, h)
	state.resize(w, h)
end

function love.draw()
	state.draw()
end

function love.quit()
	console.quit()
end

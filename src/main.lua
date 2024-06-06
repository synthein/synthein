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

local state_functions = {
	"load",
	"cursorpressed",
	"cursorreleased",
	"pressed",
	"released",
	"mousemoved",
	"wheelmoved",
	"textinput",
	"update",
	"resize",
	"draw",
}

for stateName, gameState in pairs(gameStates) do
	for _, functionName in ipairs(state_functions) do
		if not gameState[functionName] then
			error(stateName .. " is missing function: " .. functionName)
		end
	end
end

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
	--test             Run the test suite.
	--scene=NAME       Bypass all menus and jump straight into a scene.
	--log-level=LEVEL  Show logs with LEVEL severity or higher. ERROR, WARN, INFO, or DEBUG
	--debug            Enable debug mode. Implies --log-level=DEBUG.
	--help             Print this usage message.]]

function love.load()
	setGameState("MainMenu")

	Controls.loadDefaultMap()

	for _, argn in ipairs(arg) do
		if argn == "--unit-tests" then
			require("tests")
			love.event.quit()

		elseif argn:match("^%-%-scene") then
			local scene = argn:match("^%-%-scene=(%g+)")

			if scene then
				local fileName = string.format(Settings.scenesDir .. scene .. ".txt")

				setGameState("InGame", {love.filesystem.lines(fileName), {}, false})
			else
				error(
					"--scene must have an argument. You provided these arguments: "
					.. table.concat(arg, " "))
			end

		elseif argn:match("^%-%-log%-level") then
			local level = argn:match("^%-%-log%-level=(%g+)")

			if level then
				if log.levels[level] then
					Settings.logLevel = level
				else
					error("Invalid log level '" .. level .. "'")
				end
			else
				error(
					"--log-level must have an argument. You provided these arguments: "
					.. table.concat(arg, " "))
			end

		elseif argn == "--debug" then
			Settings.logLevel = "DEBUG"
			Settings.debug = true

		elseif argn == "--help" then
			print(usage)
			love.event.quit()
		end
	end
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end

	local control = Controls.lookupKey(key)
	if control then
		state.pressed(control)
	end
end

function love.keyreleased()
	local control = Controls.lookupKey(key)
	if control then
		state.released(control)
	end
end

function love.mousepressed(x, y, button)
	local control = Controls.lookupMouseButton(button)
	if control then
		state.cursorpressed({x = x, y = y}, control)
	end
end

function love.mousereleased(x, y, button)
	local control = Controls.lookupMouseButton(button)
	if control then
		state.cursorreleased(cursor, control)
	end
end

function love.mousemoved(x, y)
	local control = Controls.lookupMouseCursor()
	if control then
		state.mousemoved({x = x, y = y}, control)
	end
end

function love.wheelmoved(x, y)
	local control = Controls.lookupMouseWheel()
	if control then
		state.wheelmoved({x = x, y = y}, control)
	end
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
	if control then
		state.pressed(control)
	end

	state.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	local control = Controls.lookupJoystickButton(joystick, button)
	if control then
		state.released(control)
	end

	state.joystickreleased(joystick, button)
end

function love.textinput(key)
	state.textinput(key)
end

function love.update(dt)
	local startTime = love.timer.getTime( )
	--TODO Axis control inputs
	--TODO Compouned cursors
	--TODO ???? Controls.lookupJoystickAxis(joystick, axis)
	
	state.update(dt)
	local endTime = love.timer.getTime( )
	local duration = endTime - startTime
	if duration > 0.01 then
		log:warn("Update took too long: " .. duration)
	end
end

function love.resize(w, h)
	state.resize(w, h)
end

function love.draw()
	local startTime = love.timer.getTime( )
	state.draw()
	local endTime = love.timer.getTime( )
	local duration = endTime - startTime
	if duration > 0.01 then
		log:warn("Drawing took too long: " .. duration)
	end
end

function love.quit()
	console.quit()
end

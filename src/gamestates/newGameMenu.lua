local Menu = require("menu")
local Settings = require("settings")

local GameState = require("gamestates/gameState")
local NewGameMenu = GameState()

local modes = {"Single Player", "COOP", "Allied", "VS"}
NewGameMenu.menu = Menu.create(250, 5, modes)

function NewGameMenu.NewGame(mode)
	local scene, playerHostility
	if mode == "Single Player" then
		scene = "startScene"
		playerHostility = {{false}}
	elseif mode == "COOP" then
		scene = "startSceneCOOP"
		playerHostility = {{false, false}, {false, false}}
	elseif mode == "Allied" then
		scene = "startSceneTwoPlayer"
		playerHostility = {{false, false}, {false, false}}
	elseif mode == "VS" then
		scene = "startSceneTwoPlayer"
		playerHostility = {{false, true}, {true, false}}
	end

	if scene then
		local fileName = string.format(Settings.scenesDir .. scene .. ".txt")

		setGameState(
			"InGame",
			{love.filesystem.lines(fileName), playerHostility, false})
	end
end

function NewGameMenu.update(dt)
	NewGameMenu.menu:update(dt)
end

function NewGameMenu.draw()
	NewGameMenu.menu:draw()
	love.graphics.print("ws: Forward and Backward\n" ..
						"ad: Turn Left and Right\n" ..
						"qe: Strafe Left and Right\n" ..
						"p: pause\nESC: menu\n" ..
						"Left Click: Construcuting Ships\n" ..
						"Right Click: Deconstructing Ships", 5, 5)
end

function NewGameMenu.keypressed(key)
	NewGameMenu.testButton(NewGameMenu.menu:keypressed(key))
end

function NewGameMenu.mousepressed(x, y, mouseButton)
	if mouseButton == 1 then
		NewGameMenu.testButton(NewGameMenu.menu:getButtonAt(x, y))
	end
end

function NewGameMenu.gamepadpressed(joystick, button)
	NewGameMenu.testButton(NewGameMenu.menu:gamepadpressed(button))
end

function NewGameMenu.testButton(button, back)
	if back then
		setGameState("MainMenu")
	end

	NewGameMenu.NewGame(modes[button])
end

function NewGameMenu.resize(w, h)
	NewGameMenu.menu:resize(w, h)
end

function NewGameMenu.mousemoved(x, y)
	NewGameMenu.menu:mousemoved(x, y)
end

function NewGameMenu.wheelmoved(x, y)
	NewGameMenu.menu:wheelmoved(x, y)
end

return NewGameMenu

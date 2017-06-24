local GameState = require("gamestates/gameState")
local InGame = require("gamestates/inGame")
local Menu = require("menu")

local InitWorld = require("initWorld")
local AI = require("ai")

local NewGameMenu = {}
setmetatable(NewGameMenu, GameState)

function NewGameMenu.update(dt)
	InitWorld.init("startScene", false)
	return InGame
end

NewGameMenu.font = love.graphics.newFont(36)
local buttonNames = {"Single Player", "COOP", "Allied", "VS"}
NewGameMenu.menu = Menu.create(love.graphics.getWidth()/2, 250, 5, buttonNames)

function NewGameMenu.draw()
	previousFont = love.graphics.getFont()
	love.graphics.setFont(NewGameMenu.font)
	love.graphics.print("SYNTHEIN", (SCREEN_WIDTH - 200)/2 + 10, 175 , 0, 1, 1, 0, 0, 0, 0)
	NewGameMenu.menu:draw()
	love.graphics.setFont(previousFont)
	love.graphics.print("ws: Forward and Backward\n" ..
						"ad: Turn Left and Right\n" ..
						"qe: Strafe Left and Right\n" ..
						"p: pause\nESC: menu\n" ..
						"Left Click: Construcuting Ships\n" ..
						"Right Click: Deconstructing Ships", 5, 5)
end

function NewGameMenu.update(dt)
	return NewGameMenu
end

function NewGameMenu.mousepressed(x, y, mouseButton)
	local button = NewGameMenu.menu:pressed(x, y)
	if mouseButton == 1 then
		if button == "Single Player" then
			InitWorld.init("startScene", false)
			return InGame
		elseif button == "COOP" then
			InitWorld.init("startSceneCOOP", false)
			return InGame
		elseif button == "Allied" then
			InitWorld.init("startSceneTwoPlayer", false)
			AI.teamHostility = {{false, true,  false},
								{true,  false, true },
								{false, true,  false}}
			return InGame
		elseif button == "VS" then
			InitWorld.init("startSceneTwoPlayer", false)
			AI.teamHostility = {{false, true,  true },
								{true,  false, true },
								{true,  true,  false}}
			return InGame
		end
	end
	return NewGameMenu
end

return NewGameMenu

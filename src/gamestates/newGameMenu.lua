local GameState = require("gamestates/gameState")
local InGame = require("gamestates/inGame")
local Menu = require("menu")

local World = require("world")
local InitWorld = require("initWorld")
local AI = require("ai")

local NewGameMenu = {}
setmetatable(NewGameMenu, GameState)

local buttonNames = {"Single Player", "COOP", "Allied", "VS"}
NewGameMenu.menu = Menu.create(love.graphics.getWidth()/2, 250, 5, buttonNames)

function NewGameMenu.draw()
	NewGameMenu.menu:draw()
	love.graphics.print("ws: Forward and Backward\n" ..
						"ad: Turn Left and Right\n" ..
						"qe: Strafe Left and Right\n" ..
						"p: pause\nESC: menu\n" ..
						"Left Click: Construcuting Ships\n" ..
						"Right Click: Deconstructing Ships", 5, 5)
end

function NewGameMenu.mousepressed(x, y, mouseButton)
	local button = NewGameMenu.menu:pressed(x, y)
	if mouseButton == 1 then
		if button == "Single Player" then
			InitWorld.init("startScene", false)
			table.insert(NewGameMenu.stack, InGame)
		elseif button == "COOP" then
			InitWorld.init("startSceneCOOP", false)
			table.insert(NewGameMenu.stack, InGame)
		elseif button == "Allied" then
			InitWorld.init("startSceneTwoPlayer", false)
			World.playerHostility = {{false, false},
									 {false, false}}
			table.insert(NewGameMenu.stack, InGame)
		elseif button == "VS" then
			InitWorld.init("startSceneTwoPlayer", false)
			World.playerHostility = {{false, true},
									 {true, false}}
			table.insert(NewGameMenu.stack, InGame)
		end
	end
end

return NewGameMenu

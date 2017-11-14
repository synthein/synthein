local GameState = require("gamestates/gameState")
local InGame = require("gamestates/inGame")
local Menu = require("menu")
local InitWorld = require("initWorld")

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
		local start = true
		if button == "Single Player" then
			InitWorld.init("startScene", {{false}}, false)
		elseif button == "COOP" then
			InitWorld.init("startSceneCOOP",
						   {{false, false}, {false, false}},
						   false)
		elseif button == "Allied" then
			InitWorld.init("startSceneTwoPlayer",
						   {{false, false}, {false, false}},
						   false)
		elseif button == "VS" then
			InitWorld.init("startSceneTwoPlayer",
						   {{false, true}, {true, false}},
						   false)
		else
			start = false
		end

		if start then
			GameState.stackReplace(InGame)
		end
	end
end

return NewGameMenu

local GameState = require("gamestates/gameState")
local InitWorld = require("gamestates/initWorld")
local Menu = require("menu")

local NewGameMenu = {}
setmetatable(NewGameMenu, GameState)

local buttonNames = {"Single Player", "COOP", "Allied", "VS"}
NewGameMenu.menu = Menu.create(love.graphics.getWidth()/2, 250, 5, buttonNames)

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
	if key == "escape" then
		GameState.stackPop()
	end

	local button = NewGameMenu.menu:keypressed(key)
	local start = true
	if button == "Single Player" then
		InitWorld.scene = "startScene"
		InitWorld.playerHostility = {{false}}
	elseif button == "COOP" then
		InitWorld.scene = "startSceneCOOP"
		InitWorld.playerHostility = {{false, false}, {false, false}}
	elseif button == "Allied" then
		InitWorld.scene = "startSceneTwoPlayer"
		InitWorld.playerHostility = {{false, false}, {false, false}}
	elseif button == "VS" then
		InitWorld.scene = "startSceneTwoPlayer"
		InitWorld.playerHostility = {{false, true}, {true, false}}
	else
		start = false
	end

	if start then
		InitWorld.ifSave = false
		GameState.stackReplace(InitWorld)
	end
end

function NewGameMenu.mousepressed(x, y, mouseButton)
	local button = NewGameMenu.menu:pressed(x, y)
	if mouseButton == 1 then
		local start = true
		if button == "Single Player" then
			InitWorld.scene = "startScene"
			InitWorld.playerHostility = {{false}}
		elseif button == "COOP" then
			InitWorld.scene = "startSceneCOOP"
			InitWorld.playerHostility = {{false, false}, {false, false}}
		elseif button == "Allied" then
			InitWorld.scene = "startSceneTwoPlayer"
			InitWorld.playerHostility = {{false, false}, {false, false}}
		elseif button == "VS" then
			InitWorld.scene = "startSceneTwoPlayer"
			InitWorld.playerHostility = {{false, true}, {true, false}}
		else
			start = false
		end

		if start then
			InitWorld.ifSave = false
			GameState.stackReplace(InitWorld)
		end
	end
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

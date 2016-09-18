--local Debug = require("debugTools")
local Player = require("player")
local Structure = require("structure")
local World = require("world")
local Screen = require("screen")
local Util = require("util")
local SceneParser = require("sceneParser")

local GameState = require("gamestates/gameState")

local InGame = {}
setmetatable(InGame, GameState)

local world
local players = {}
local paused = false

function InGame.setplayers(playerTable)
	players = playerTable
end

function InGame.setWorld(setworld)
	world = setworld
end

function InGame.update(dt)
	if paused then
	else
		Structure.physics:update(dt)

		Screen.camera:setX(players[1].ship.body:getX())
		Screen.camera:setY(players[1].ship.body:getY())

		players[1]:handleInput(Screen.camera:getPosition())
		world:update(dt)
	end
	return InGame
end

function InGame.draw()
	-- for camera in InGame.cameras do
		cameraX, cameraY = Screen.camera:getPosition()
	--todo move to Camera/Screen
		--love.graphics.translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
		--love.graphics.translate(-cameraX, cameraY)
	--
		world:draw()
		players[1].cursorX = love.mouse.getX()
		players[1].cursorY = love.mouse.getY()
		players[1]:draw()
		love.graphics.origin()
		love.graphics.draw(
			compass,
			SCREEN_WIDTH-60,
			SCREEN_HEIGHT-60,
			-math.atan2(cameraY, cameraX)-math.pi/2,
			1, 1, 25, 25)
	-- end
	if paused then
		love.graphics.print(
			"Paused",
			SCREEN_WIDTH/2-24,
			SCREEN_HEIGHT/2-30)
	end
	if quitting then
		love.graphics.print(
			"Do you want to quit?",
			SCREEN_WIDTH/2-64,
			SCREEN_HEIGHT/2-30)
	end
	return InGame
end

function InGame.keypressed(key)
	if key == "p" then
		paused = not paused
	end
	if key == "v" then
		SceneParser.saveScene("synthienSave", world)
	end
	return InGame
end

function InGame.mousepressed(x, y, button)
	players[1].cursorX = x
	players[1].cursorY = y
	players[1]:mousepressed(button)
	return InGame
end

function InGame.mousereleased(x, y, button)
	players[1].cursorX = x
	players[1].cursorY = y
	players[1]:mousereleased(button)
	return InGame
end

return InGame

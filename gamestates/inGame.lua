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
local eventTime = 0
local second = 0

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

		eventTime = eventTime + dt
		second = second + dt
		if second > 1 then
			timeVar = 1 - 50/(20 + eventTime)
			if timeVar < 0 then timeVar = 0 end
			disVar = 1 - 50/(1 + Util.vectorMagnitude(
						players[1].ship.body:getX(),players[1].ship.body:getY())/20)
			if disVar < 0 then disVar = 0 end
			veloVar = 1 - 50/(1 + Util.vectorMagnitude(
						players[1].ship.body:getLinearVelocity()))
			if veloVar < 0 then veloVar = 0 end
			rand = love.math.random()
			if rand < timeVar * disVar * veloVar then
				eventTime = 0
				local scene = math.floor(love.math.random() * 10)
				scene = tostring(scene)
				SceneParser.loadScene("scene" .. scene, {players[1].ship.body:getX(),players[1].ship.body:getY()})
			end
			second = second - 1
		end
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
		SceneParser.saveScene("syntheinSave", world)
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

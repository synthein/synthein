local Debug = require("debugTools")
local Player = require("player")
local Structure = require("structure")
local World = require("world")

local InGame = {}

local world
local paused = false

function InGame.setWorld(setworld)
	world = setworld
end

function InGame.update(dt)
	if paused then
	else
		physics:update(dt)

		globalOffsetX = player1.ship.body:getX()
		globalOffsetY = player1.ship.body:getY()
		mouseWorldX = love.mouse.getX() - SCREEN_WIDTH/2 + globalOffsetX
		mouseWorldY = love.mouse.getY() - SCREEN_HEIGHT/2 + globalOffsetY

		world:update(dt)
		player1:handleInput(globalOffsetX, globalOffsetY)
	end
	return InGame
end

function InGame.draw()
	mouseWorldX = love.mouse.getX() - SCREEN_WIDTH/2 + globalOffsetX
	mouseWorldY = love.mouse.getY() - SCREEN_HEIGHT/2 + globalOffsetY
	love.graphics.translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
	world:draw()
	player1:draw(globalOffsetX, globalOffsetY, mouseWorldX, mouseWorldY)
	love.graphics.translate(-SCREEN_WIDTH/2, -SCREEN_HEIGHT/2)
	love.graphics.draw(
		compass,
		SCREEN_WIDTH-60,
		SCREEN_HEIGHT-60,
		math.atan2(globalOffsetY, globalOffsetX)-math.pi/2,
		1, 1, 25, 25)
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
	return InGame
end

function InGame.mousepressed(x, y, button)
	player1:mousepressed(x, y, button)
	return InGame
end

function InGame.mousereleased(x, y, button)
		player1:mousereleased(x, y, button)
	return InGame
end

return InGame

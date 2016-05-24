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

		camera.setX(player1.ship.body:getX())
		camera.setY(player1.ship.body:getY())
		mouseWorldX = love.mouse.getX() - SCREEN_WIDTH/2 + camera.getX()
		mouseWorldY = love.mouse.getY() - SCREEN_HEIGHT/2 + camera.getY()

		world:update(dt)
		player1:handleInput(camera.getPosition())
	end
	return InGame
end

function InGame.draw()
	-- for camera in InGame.cameras do
		cameraX, cameraY = camera.getPosition()
		mouseWorldX = love.mouse.getX() - SCREEN_WIDTH/2 + cameraX
		mouseWorldY = love.mouse.getY() - SCREEN_HEIGHT/2 + cameraY
		love.graphics.translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
		world:draw(cameraX, cameraY)
		player1:draw(cameraX, cameraY, mouseWorldX, mouseWorldY)
		love.graphics.translate(-SCREEN_WIDTH/2, -SCREEN_HEIGHT/2)
		love.graphics.draw(
			compass,
			SCREEN_WIDTH-60,
			SCREEN_HEIGHT-60,
			math.atan2(cameraY, cameraX)-math.pi/2,
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
	return InGame
end

function InGame.mousepressed(x, y, button)
	cameraX, cameraY = camera.getPosition()
	mouseWorldX = love.mouse.getX() - SCREEN_WIDTH/2 + cameraX
	mouseWorldY = love.mouse.getY() - SCREEN_HEIGHT/2 + cameraY

	player1:mousepressed(mouseWorldX, mouseWorldY, button)
	return InGame
end

function InGame.mousereleased(x, y, button)
	cameraX, cameraY = camera.getPosition()
	mouseWorldX = love.mouse.getX() - SCREEN_WIDTH/2 + cameraX
	mouseWorldY = love.mouse.getY() - SCREEN_HEIGHT/2 + cameraY

	player1:mousereleased(x, y, button)
	return InGame
end

return InGame

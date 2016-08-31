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

		world:update(dt)
		player1:handleInput(camera.getPosition())
	end
	return InGame
end

function InGame.draw()
	-- for camera in InGame.cameras do
		cameraX, cameraY = camera.getPosition()
	--todo move to Camera/Screen
		love.graphics.translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
		love.graphics.translate(-cameraX, cameraY)
	--
		world:draw()
		player1.cursorX = love.mouse.getX()
		player1.cursorY = love.mouse.getY()
		player1:draw()
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
	return InGame
end

function InGame.mousepressed(x, y, button)
	player1.cursorX = x
	player1.cursorY = y
	player1:mousepressed(button)
	return InGame
end

function InGame.mousereleased(x, y, button)
	player1.cursorX = x
	player1.cursorY = y
	player1:mousereleased(mouseWorldX, mouseWorldY, button)
	return InGame
end

return InGame

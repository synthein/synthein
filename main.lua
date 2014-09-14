local Anchor = require("anchor")
local Block = require("block")
local Input = require("input")
local Player = require("player")
local Structure = require("structure")

function love.load()
	love.physics.setMeter(20) -- there are 20 pixels per meter
	world = love.physics.newWorld()

	compass = love.graphics.newImage("res/images/compass.png")
	playerShip = Structure.create(Player.create(), world, 0, -100)
	anchor = Structure.create(Anchor.create(), world, 0, 0)

	player1 = Input.create("player1", playerShip)

	worldStructures = {}
	for i=1,10 do
		worldStructures[i] = Structure.create(Block.create(), world, i*35, i*35)
	end
end

function love.update(dt)
	world:update(dt)
	playerX = playerShip.body:getX()
	playerY = playerShip.body:getY()
	player1:handleInput()
end

function love.draw()
	playerShip:draw()
	anchor:draw(angle, playerX, playerY)
	for i=1,10 do
		worldStructures[i]:draw(playerX, playerY)
	end
	love.graphics.draw(compass, love.graphics.getWidth()-60, love.graphics.getHeight()-60, math.atan2(playerShip.body:getY(), playerShip.body:getX())-math.pi/2, 1, 1, 25, 25)
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit") end
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end

	--------------------
	-- Debug Commands --
	--------------------

	--------------------
end

local Player = require("player")
local Anchor = require("anchor")
local Block = require("block")
local Structure = require("structure")

function love.load()
	love.physics.setMeter(20) -- there are 20 pixels per meter
	world = love.physics.newWorld()

	compass = love.graphics.newImage("res/images/compass.png")
	playerShip = Structure.createPlayerShip(Player.create(), world, 0, -100)

	anchor = Structure.createAnchor(Anchor.create(), world, 0, 0)

	blocks = {}
	for i=1,10 do
		blocks[i] = Structure.create(Block.create(), world, i*35, i*35)
	end

	for i=4,10 do
		blocks[1]:merge(blocks[i], blocks[i].parts[1], nil, nil)
	end

end

function love.update(dt)
	world:update(dt)

	playerX = playerShip.body:getX()
	playerY = playerShip.body:getY()

	playerShip:handleInput()
end

function love.draw()
	playerShip:draw()
	anchor:draw(angle, playerX, playerY)
	for i=1,10 do
		blocks[i]:draw(playerX, playerY)
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

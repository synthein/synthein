local Player = require("player")
local Anchor = require("anchor")
local Block = require("block")
local Structure = require("structure")

function love.load()
	love.physics.setMeter(20) -- there are 20 pixels per meter
	world = love.physics.newWorld()
    
	compass = love.graphics.newImage("res/images/compass.png")
	player = Player.create(world, 0, -100)
	anchor = Anchor.create(world, 0, 0)

	blocks = {}
	for i=1,10 do
		blocks[i] = Block.create(world, i*30, i*30)
	end
end

function love.update(dt)
	world:update(dt)

	playerX = player.body:getX()
	playerY = player.body:getY()

	player:update(dt)
end

function love.draw()
	player:draw()
	anchor:draw(playerX, playerY)
	for i=1,10 do
		blocks[i]:draw(playerX, playerY)
	end
	love.graphics.draw(compass, love.graphics.getWidth()-60, love.graphics.getHeight()-60, math.atan2(player.body:getY(), player.body:getX())-math.pi/2, 1, 1, 25, 25)
	love.graphics.print(player.body:getX().." "..player.body:getY().." "..player.body:getAngle(), 1, 1)
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit") end
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
	if key == "c" then --debug
		struct1 = Structure.create(blocks[1])
		struct1:addBlock(blocks[2], blocks[1], "right")
	end
end

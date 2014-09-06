local Player = require("player")
local Anchor = require("anchor")

function love.load()
	love.physics.setMeter(20) -- there are 20 pixels per meter
	world = love.physics.newWorld()
    
	player = Player.create(world, 100, 100)
	anchor = Anchor.create(world, 0, 0)
end

function love.update(dt)
	world:update(dt)

	playerX = player.body:getX()
	playerY = player.body:getY()

	player:update(dt)
	anchor:update(dt)
end

function love.draw()
	player:draw()
	anchor:draw(playerX, playerY)
	love.graphics.print(player.body:getX().." "..player.body:getY().." "..player.body:getAngle(), 1, 1)
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit") end
end

local Player = require("player")
local Anchor = require("anchor")

function love.load()
	love.physics.setMeter(20) -- there are 20 pixels per meter
	world = love.physics.newWorld()
    
	compass = love.graphics.newImage("compass.png")
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
	love.graphics.draw(compass, love.graphics.getWidth()-60, love.graphics.getHeight()-60, math.atan2(player.body:getY(), player.body:getX())-math.pi/2, 1, 1, 25, 25)
	love.graphics.print(player.body:getX().." "..player.body:getY().." "..player.body:getAngle(), 1, 1)
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit") end
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
end

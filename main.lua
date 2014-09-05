Player = require("player")
Anchor = require("anchor")

function love.load()
	world = love.physics.newWorld()
    
	player = Player.create(world)
	anchor = Anchor.create(world)
end

function love.update(dt)
	world:update(dt)
	player:update()
	anchor:update()
end

function love.draw()
	love.graphics.print(player.body:getX().." "..player.body:getY().." "..player.body:getAngle(), 1, 1)
	player:draw()
	anchor:draw()
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit") end
end

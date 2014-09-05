require("player")
require("anchor")

function love.load()
    WIDTH, HEIGHT = love.graphics.getDimensions()
    
	player = Player.create()
	anchor = Anchor.create()
end

function love.update(dt)
	player:update()
	anchor:update()
end

function love.draw()
	player:draw()
	anchor:draw()
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit") end
end

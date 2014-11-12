local Part = require("part")

local Engine = {}
Engine.__index = Engine
setmetatable(Engine, Part)

function Engine.create(world, x, y)
	local self = Part.create("engine")
	setmetatable(self, Engine)

	self.isActive = false
	self.imageActive = love.graphics.newImage("res/images/engineActive.png")
	self.shape = love.physics.newRectangleShape(self.width, self.height)

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	self.thrust = 250

	return self
end

function Engine:draw(x, y, angle, globalOffsetX, globalOffsetY)
	local image
	if self.isActive then
		image = self.imageActive
	else
		image = self.image
	end

	love.graphics.draw(
		image,
		love.graphics.getWidth()/2 - globalOffsetX + x,
		love.graphics.getHeight()/2 - globalOffsetY + y,
		angle, 1, 1, self.width/2, self.height/2)
end

return Engine

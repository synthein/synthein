local Part = require("part")
local Screen = require("screen")

local Engine = {}
Engine.__index = Engine
setmetatable(Engine, Part)

function Engine.create(world, x, y)
	local self = Part.create()
	setmetatable(self, Engine)

	self.image = love.graphics.newImage("res/images/engine.png")
	self.isActive = false
	self.imageActive = love.graphics.newImage("res/images/engineActive.png")
	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	self.thrust = 250

	return self
end

function Engine:draw(x, y, angle)
	local image
	if self.isActive then
		image = self.imageActive
	else
		image = self.image
	end
	Screen.draw(
		image,
		x,
		y,
		angle, 1, 1, self.width/2, self.height/2)
end

return Engine

local Part = require("part")

local Engine = {}
Engine.__index = Engine
setmetatable(Engine, Part)

function Engine.create(world, x, y)
	local self = Part.create("engine")
	setmetatable(self, Engine)

	self.shape = love.physics.newRectangleShape(self.width, self.height)

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	self.thrust = 250

	return self
end

return Engine

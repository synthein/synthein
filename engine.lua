local Part = require("part")

local Engine = {}
Engine.__index = Engine
setmetatable(Engine, Part)

function Engine.create(world, x, y)
	local self = Part.create("engine")
	setmetatable(self, Engine)

	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.thrust = 250

	return self
end

return Engine

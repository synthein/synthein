local Part = require("part")

local Gun = {}
Gun.__index = Gun
setmetatable(Gun, Part)

function Gun.create(world, x, y)
	local self = Part.create("gun")
	setmetatable(self, Gun)

	self.shape = love.physics.newRectangleShape(self.width, self.height)

	-- Guns can only connect to things on their bottom side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	return self
end

return Gun

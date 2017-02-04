local Screen = require("screen")

local Part = {}
Part.__index = Part

function Part.create()
	local self = {}
	setmetatable(self, Part)

	self.physicsShape = nil
	self.connectableSides = {true, true, true, true}
	self.thrust = 0
	self.torque = 0
	self.gun = false
	self.destroy = false
	self.type = "generic"
	self.health = 10

	return self
end

function Part:loadData(data)
	if data[1] then self.health = data[1] end
end

function Part:saveData()
	return {self.health}
end

function Part:takeDamage()
	self.health = self.health - 1
	if self.health <= 0 then
		self.destroy = true
	end
end

function Part:update(dt, commands)
end

function Part:draw(x, y, angle)
	Screen.draw(
		self.image,
		x,
		y,
		angle, 1, 1, self.width/2, self.height/2)
end

return Part

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
	self.isDestroyed = false
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

function Part:setLocation(location, locationInfo, orientation)
	if locationInfo then
		local l = locationInfo[1]
		local dX = locationInfo[2][1]
		local dY = locationInfo[2][2]
		local x = (location[1] * dX - location[2] * dY) * 20 + l[1]
		local y = (location[1] * dY + location[2] * dX) * 20 + l[2]
		local angle = (orientation - 1) * math.pi/2 + l[3]
		self.location = {x, y, angle}
	else
		self.location = location
	end
end

function Part:takeDamage()
	self.health = self.health - 1
	if self.health <= 0 then
		self.isDestroyed = true
	end
end

function Part:update(dt, partsInfo, location, locationSign, orientation)
	self:setLocation(location, partsInfo.locationInfo, orientation)
end

function Part:draw()
	if self.location then
		Screen.draw(
			self.image,
			self.location[1],
			self.location[2],
			self.location[3], 1, 1, self.width/2, self.height/2)
	end
end

return Part

local Settings = require("settings")
local Util = require("util")

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

function Part:setFixture(fixture)
	if self.fixture then self.fixture:destroy() end
	self.fixture = fixture
	self.fixture:setUserData(self)
end

function Part:setLocation(location)
	self.location = location
end

function Part:withinPart(x, y)
	return self.fixture:testPoint(x, y)
end

function Part:getWorldLocation()
	if not self.fixture:isDestroyed() then
		local body = self.fixture:getBody()
		if self.location and body then
			local angle = (self.location[3] - 1) * math.pi/2 + body:getAngle()
			local x, y = unpack(self.location)
			x, y = body:getWorldPoints(x * Settings.PARTSIZE,
									   y * Settings.PARTSIZE)
			self.worldLocation = {x, y, angle}
		end
	end

	local a, b, c
	if self.worldLocation then
		a, b, c = unpack(self.worldLocation)
	end
	return a, b, c
end

function Part:getPartSide(locationX, locationY)
	local partX, partY, partAngle = self:getWorldLocation()
	local angleToCursor = Util.vectorAngle(locationX - partX,
										   locationY - partY)
	local angleDifference = angleToCursor - partAngle
	partSide = math.floor((angleDifference*2/math.pi - 1/2) % 4 +1)
	return partSide
end

function Part:damage(damage)
	self.health = self.health - damage
	if self.health <= 0 then
		local structure = self.fixture:getBody():getUserData()
		local events = structure.events
		table.insert(events.create, {"particles", {self:getWorldLocation()}})
		self.fixture:destroy()
		structure:removePart(self)
		if not structure.isDestroyed then
			structure:removeSections()
		end
		self.isDestroyed = true
	end
end

function Part:collision(fixture, sqVelocity, pointVelocity)
	object = fixture:getUserData()
	x, y, mass, inertia = fixture:getMassData()
	local partSize = Settings.PARTSIZE
	local div = partSize * partSize
	local damage = math.floor(sqVelocity * mass * 10 / div / div)
	object:damage(damage)
	local body = self.fixture:getBody()
	local mult = -damage * partSize

	local xI, yI = unpack(pointVelocity)
	if xI and yI then
		body:applyLinearImpulse(xI * mult, yI * mult)
	end
end

function Part:update(dt, partsInfo)
end

function Part:draw(camera)
	local x, y, angle = self:getWorldLocation()
	if x and y and angle then
		camera:draw(self.image, x, y, angle, 1, 1, self.width/2, self.height/2)
	end
end

return Part

local PhysicsReferences = require("world/physicsReferences")

local Sensor = class()

function Sensor:__create(size)
	self.size = size
	return self
end

function Sensor:update(moduleInputs, location)

end

function Sensor:addFixtures(body, x, y)
	local shape = love.physics.newCircleShape(x, y, self.size)
	self.fixture = love.physics.newFixture(body, shape)
	PhysicsReferences.setFixtureType(self.fixture, "camera")

	local userData = {
		collision = function() end
	}
	self.fixture:setUserData(userData)
end

function Sensor:removeFixtures()
	self.fixture:destroy()
end

return Sensor

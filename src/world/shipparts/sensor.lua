local PhysicsReferences = require("world/physicsReferences")

local Sensor = class()

function Sensor:__create(size)
	self.size = size
	self.bodyList = {}
	return self
end

function Sensor:update(moduleInputs, location)

end

function Sensor:addFixtures(body, x, y)
	local shape = love.physics.newCircleShape(x, y, self.size)
	self.fixture = love.physics.newFixture(body, shape)
	PhysicsReferences.setFixtureType(self.fixture, "camera")

	local bodyList = self.bodyList
	local userData = {
		collision = function(object, fixtureA, fixtureB, sqV, aL)
			local body = fixtureB:getBody()
			if not bodyList[body] then bodyList[body] = {} end
			bodyList[body][fixtureB] = true
		end,

		endCollision = function(object, fixtureA, fixtureB, sqV, aL)
			local body = fixtureB:getBody()
			bodyList[body][fixtureB] = nil
			if next(bodyList[body]) == nil then bodyList[body] = nil end
		end
	}

	self.fixture:setUserData(userData)
end

function Sensor:removeFixtures()
	self.fixture:destroy()
end

return Sensor

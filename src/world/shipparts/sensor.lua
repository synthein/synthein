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
		collision = function(fixtureA, fixtureB, sqV, aL)
			local bodyB = fixtureB:getBody()
			if not bodyList[bodyB] then bodyList[bodyB] = {} end
			bodyList[bodyB][fixtureB] = true
		end,

		endCollision = function(fixtureA, fixtureB, sqV, aL)
			local bodyB = fixtureB:getBody()
			bodyList[bodyB][fixtureB] = nil
			if next(bodyList[bodyB]) == nil then bodyList[bodyB] = nil end
		end
	}

	self.fixture:setUserData(userData)
end

function Sensor:removeFixtures()
	self.fixture:destroy()
	self.fixture = nil
end

function Sensor:getBodyList()
	return self.bodyList
end

return Sensor

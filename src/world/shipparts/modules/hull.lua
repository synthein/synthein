local PhysicsReferences = require("world/physicsReferences")
local Location = require("world/location")

local Hull = class()

function Hull:__create(imageFunction, maxHealth)--, connectableSides)

	self.health = maxHealth
	self.maxHealth = maxHealth
	self.isDestroyed = false

	local userData = {}

	userData.draw = function(userdata, fixture, scaleByHealth, drawMode)
		if scaleByHealth then
			local c = userData:getScaledHealth()
			love.graphics.setColor(1, c, c, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end

		local l = userData.location
		local x, y, angle = Location.fixturePoint3(fixture, l[1], l[2])
		angle = angle + (l[3] - 1) * math.pi / 2
		imageFunction(x, y, angle, drawMode)
	end

	function userData.collision(fixture, otherFixture, sqVelocity, pointVelocity)
		local object = otherFixture:getUserData()
		local _, _, mass, _ = otherFixture:getMassData()
		local damage = math.floor(sqVelocity * mass / 40)
		object:damage(otherFixture, damage)
	end

	function userData.damage(userData, fixture, damage)
		local body = fixture:getBody()
		local l = userData.location
		local location
		if body and l then
			local partX, partY, angle = unpack(l)
			local x, y = body:getWorldPoints(partX, partY)
			angle = (angle - 1) * math.pi/2 + body:getAngle()
			local vx, vy = body:getLinearVelocityFromLocalPoint(partX, partY)
			local w = body:getAngularVelocity()
			location = {x, y, angle, vx, vy, w}
		end
		self.health = self.health - damage
		if self.health <= 0 then
			self.isDestroyed = true
			self.location = location
		end
	end

	function userData.repair(repair)
		self.health = math.min(self.health + repair, self.maxHealth)
	end

	function userData.getScaledHealth()
		return self.health / self.maxHealth
	end

	self.userData = userData
end

function Hull:addFixtures(body)
	local shape = love.physics.newRectangleShape(
		self.userData.location[1],
		self.userData.location[2],
		1, 1)
	local fixture = love.physics.newFixture(body, shape)

	self.fixture = fixture

	self.fixture:setUserData(self.userData)

	PhysicsReferences.setFixtureType(self.fixture, "general")
end

function Hull:removeFixtures()
	self.fixture:destroy()
	self.fixture = nil
end

function Hull:update()
	if self.isDestroyed then
		return {"particles", {0, 0, 1}}, true
	end
end

return Hull

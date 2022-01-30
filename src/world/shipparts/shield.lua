local PhysicsReferences = require("world/physicsReferences")

local Shield = class()

function Shield:__create(body)
	self.partLocations = {}
	self.body = body
	self.collidedFixtures = {}
	self.health = 0
	self.healRate = 0
	self.maxHealth = 0
end

function Shield:createFixture()
	if self.fixture then self.fixture:destroy() end
	local partSum, x, y = 0, 0, 0
	for part, location in pairs(self.partLocations) do
		partSum = partSum + 1
		x = x + location[1]
		y = y + location[2]
	end

	if partSum == 0 then
		self.fixture = nil
		return
	end

	x = x / partSum
	y = y / partSum
	self.center = {x, y}
	self.radius = 5 * math.sqrt(partSum)
	self.healRate = partSum
	self.maxHealth = partSum * 10
	local shape = love.physics.newCircleShape(x, y, self.radius + 1)
	self.fixture = love.physics.newFixture(self.body, shape)
	PhysicsReferences.setFixtureType(self.fixture, "shield")
	self.fixture:setUserData({
		collision = function(_, fixture)
			self.collidedFixtures[fixture] = self:test(fixture)
		end,
		endCollision = function(_, fixture)
			self.collidedFixtures[fixture] = nil
		end,
		damage = function(_, _, d)
			self.health = self.health - d
			if self.health < 0 then
				self.health = 0
			end
		end,
		testPoint = function(...) return self:testPoint(...) end, --this is a place holder till I find something better
		draw = function() self:draw() end,
	})
end

function Shield:addPart(part)
	self.partLocations[part] = {part.location[1], part.location[2]}
	self:createFixture()
end

function Shield:removePart(part)
	self.partLocations[part] = nil
	self:createFixture()
end

function Shield:test(fixture)
	local x, y = self.body:getWorldPoints(unpack(self.center))
	local radius = math.min(self.health, self.radius)
	local fixtureX, fixtureY = fixture:getBody():getPosition()
	local dx = fixtureX - x
	local dy = fixtureY - y
	return (dx * dx) + (dy * dy) < radius * radius
end

function Shield:testPoint(px, py)
	local x, y = self.body:getWorldPoints(unpack(self.center))
	local radius = math.min(self.health, self.radius)
	local dx = px - x
	local dy = py - y
	return (dx * dx) + (dy * dy) < radius * radius
end

function Shield:draw()
	local x, y = self.body:getWorldPoints(unpack(self.center))
	local radius = math.min(math.sqrt(5 * self.health), self.radius)

	if radius < 1 then return end

	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(31/255, 63/255, 143/255, 95/255)
	love.graphics.circle("fill", x, y, radius)
	love.graphics.setColor(r, g, b, a)
end

function Shield:update(dt)
	self.health =math.min(self.health + dt * self.healRate, self.maxHealth)
	for fixture, value in pairs(self.collidedFixtures) do
		if self:test(fixture) and not value then
			fixture:getUserData().collision(fixture, self.fixture)
		end
	end
end

return Shield

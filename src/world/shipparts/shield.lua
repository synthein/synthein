local PhysicsReferences = require("world/physicsReferences")
local Timer = require("timer")

local Shield = class()

function Shield:__create(body)
	self.partLocations = {}
	self.center = {0, 0}
	self.body = body
	self.health = 10
	self.collidedFixtures = {}
	self.timer = Timer(5)
end

function Shield:createFixture()
	if self.fixture then self.fixture:destroy() end
	if next(self.partLocations) == nil then
		self.fixture = nil
		return
	end
	x, y = unpack(self.center)
	local shape = love.physics.newCircleShape(x, y, 6)
	self.fixture = love.physics.newFixture(self.body, shape)
	self.fixture:setUserData(self)
	PhysicsReferences.setFixtureType(self.fixture, "shield")
end

function Shield:addPart(part)
	self.partLocations[part] = {part.location[1], part.location[2]}
	self:createFixture()
end

function Shield:removePart(part)
	self.partLocations[part] = nil
	self:createFixture()
end

function Shield:collision(_, fixture)
	self.collidedFixtures[fixture] = self:test(fixture)
end

function Shield:endCollision(_, fixture)
	self.collidedFixtures[fixture] = nil
end

function Shield:test(fixture)
	local x, y = self.body:getWorldPoints(unpack(self.center))
	local radius = 5 > self.health and self.health or 5
	local fixtureX, fixtureY = fixture:getBody():getPosition()
	local dx = fixtureX - x
	local dy = fixtureY - y
	return (dx * dx) + (dy * dy) < radius * radius
end

function Shield:damage(_, d)
	self.health = self.health - d
	if self.health < 0 then
		self.health = 0
	end
end

function Shield:draw()
	local x, y = self.body:getWorldPoints(unpack(self.center))
	local radius = 5 > self.health and self.health or 5

	if radius < 1 then return end

	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(1/8, 1/4, 9/16, 3/8)
	love.graphics.circle("fill", x, y, radius)
	love.graphics.setColor(r, g, b, a)
end

function Shield:update(dt)
	if self.timer:ready(dt) then
		if self.health < 10 then
			self.health = self.health + 1
		end
	end

	for fixture, value in pairs(self.collidedFixtures) do
		if self:test(fixture) and not value then
			fixture:getUserData():collision(fixture, self.fixture)
		end
	end
end

return Shield

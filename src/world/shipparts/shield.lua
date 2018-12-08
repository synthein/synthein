local PhysicsReferences = require("world/physicsReferences")

local Shield = class()

function Shield:__create(body)
	self.partLocations = {}
	self.body = body
	self.health = 5
end

function Shield:addPart(x, y)
	if self.fixture then self.fixture:destroy() end
	table.insert(self.partLocations, {x, y})

	self.points = {x - 2.5, y - 2.5, 5, 5}

	local shape = love.physics.newRectangleShape(x,
												 y,
												 5, 5)
	self.fixture = love.physics.newFixture(self.body, shape)
	self.fixture:setUserData(self)
	PhysicsReferences.setFixtureType(self.fixture, "shield")
end

function Shield:collision()
end

function Shield:damage()
	self.health = self.health - 1
	if self.health <= 0 then
		self.fixture:destroy()
		self.fixture = nil
	end
end

function Shield:draw()
	local x, y, width, height = unpack(self.points)
	love.graphics.setLineWidth(.4)
	love.graphics.rectangle("line", x, y, width, height)
end

return Shield

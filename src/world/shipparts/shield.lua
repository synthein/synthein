local Shield = class()

function Shield:__create(body)
	self.partLocations = {}
	self.body = body
end

function Shield:addPart(x, y)
	if self.fixture then self.fixture.destroy() end
	table.insert(self.partLocations, {x, y})

	self.points = {x - 2.5, y - 2.5, 5, 5}

	local shape = love.physics.newRectangleShape(x,
												 y,
												 5, 5)
	self.fixture = love.physics.newFixture(self.body, shape)
	self.fixture:setUserData(self)
	self.fixture:setSensor(true)
end

function Shield:collision()
end

function Shield:draw()
	local x, y, width, height = unpack(self.points)
	love.graphics.setLineWidth(.4)
	love.graphics.rectangle("line", x, y, width, height)
end

return Shield

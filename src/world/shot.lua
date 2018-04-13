local Util = require("util")

local Shot = class(require("world/worldObjects"))

function Shot:__create(worldInfo, location, sourcePart)
	local imageName = "shot"
	local image = love.graphics.newImage("res/images/"..imageName..".png")
	local width = image:getWidth()
	local height = image:getHeight()
	self.drawData = {image, .1/width, -.5/height, width/2, height/2}

	local vx, vy = Util.vectorComponents(25, location[3] + math.pi/2)
	self.body:setLinearVelocity(location[4] + vx, location[5] + vy)
	self.body:setBullet(true)

	self.physicsShape = love.physics.newRectangleShape(.2, .2)
	self.fixture = love.physics.newFixture(self.body, self.physicsShape)
	self.fixture:setSensor(true)
	self.fixture:setUserData(self)
	
	self.time = 0
	self.firstContact = true
	self.sourcePart = sourcePart
end

function Shot:postCreate(references)
	local time, structure, x, y = unpack(self.sourcePart)
	self.time = time
	structure = references[structure]
	self.sourcePart = structure.gridTable:index(x, y)
end

function Shot:getSaveData(references)
	local part = self.sourcePart
	local x, y = unpack(part.location)
	local structure = part.fixture:getBody():getUserData()
	structure = references[structure]
	return {self.time, structure, x, y}
end

function Shot:collision(fixture)
	local object = fixture:getUserData()
	if object ~= self.sourcePart and self.firstContact then
		object:damage(1)
		self:destroy()
		self.firstContact = false --this is needed because of bullet body physics
	end
end

function Shot:update(dt)
	self.time = self.time + dt
	if self.time > 5 then
		self:destroy()
	end

	return {}
end

return Shot

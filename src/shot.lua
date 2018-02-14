local Util = require("util")

local Shot = {}
Shot.__index = Shot

function Shot.create(worldInfo, location, sourcePart)
	local self = {}
	setmetatable(self, Shot)

	local imageName = "shot"
	self.image = love.graphics.newImage("res/images/"..imageName..".png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	local shotVel = {Util.vectorComponents(25, location[3] + math.pi/2)}
	local partX, partY = unpack(sourcePart.location)
	local partBody = sourcePart.fixture:getBody()
	local bodyVel = {partBody:getLinearVelocityFromLocalPoint(partX, partY)}
	local vx = shotVel[1] + bodyVel[1]
	local vy = shotVel[2] + bodyVel[2]

	self.physics = worldInfo.physics
	self.events = worldInfo.events
	self.body = love.physics.newBody(self.physics,
					location[1], location[2], "dynamic")
	self.body:setAngle(location[3])
	self.body:setLinearVelocity(vx, vy)
	self.body:setBullet(true)
	self.physicsShape = love.physics.newRectangleShape(.2, .2)
	self.fixture = love.physics.newFixture(self.body, self.physicsShape)
	self.fixture:setSensor(true)
	self.fixture:setUserData(self)
	self.time = 0
	self.isDestroyed = false
	self.firstContact = true

	self.sourcePart = sourcePart
	return self
end

function Shot:postCreate(references)
	local time, structure, x, y = unpack(self.sourcePart)
	self.time = time
	structure = references[structure]
	self.sourcePart = structure.gridTable:index(x, y)
end

function Shot:getLocation()
	return self.body:getX(), self.body:getY(), self.angle
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

function Shot:destroy()
	self.body:destroy()
	self.isDestroyed = true
end


function Shot:update(dt)
	self.time = self.time + dt
	if self.time > 5 then
		self:destroy()
	end

	return {}
end

function Shot:draw()
	love.graphics.draw(
		self.image,
		self.body:getX(), self.body:getY(), self.body:getAngle(),
		.1/self.width, -.5/self.height, self.width/2, self.height/2)
end

return Shot

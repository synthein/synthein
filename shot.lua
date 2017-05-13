local Util = require("util")
local Screen = require("screen")

local Shot = {}
Shot.__index = Shot

Shot.physics = nil

function Shot.setPhysics(setphysics)
	Shot.physics = setphysics
end

function Shot.create(location, sourcePart)
	local self = {}
	setmetatable(self, Shot)
	local imageName = "shot"
	self.image = love.graphics.newImage("res/images/"..imageName..".png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.body = love.physics.newBody(Shot.physics, 
					location[1], location[2], "dynamic")
	self.body:setAngle(location[3])
	self.body:setLinearVelocity(
				Util.vectorComponents(500, location[3] + math.pi/2))
	self.body:setBullet(true)
	self.physicsShape = love.physics.newRectangleShape(2, 2)
	self.fixture = love.physics.newFixture(self.body, self.physicsShape)
	self.fixture:setSensor(true)
	self.time = 0
	self.isDestroyed = false

	self.sourcePart = sourcePart
	return self
end

function Shot:getLocation()
	return self.body:getX(), self.body:getY(), self.angle
end

function Shot:update(dt, worldInfo)
	self.time = self.time + dt
	if self.time > 5 then
		self.isDestroyed = true
	end

	local newObjects = {}
	for i, structure in ipairs(worldInfo[2].structures) do
		local partIndexHit = structure:getPartIndex(self.body:getPosition())
		if partIndexHit then
			local structureHit = structure
			local partHit = structureHit.parts[partIndexHit]
			local hit =
				structureHit and
				partIndexHit and
				partHit ~= self.sourcePart
			if hit then
				self.isDestroyed = true
				partHit:takeDamage()
			end
		end
	end
	return newObjects
end

function Shot:draw()
	Screen.draw(
		self.image,
		self.body:getX(), self.body:getY(), self.body:getAngle(),
		1, 1, self.width/2, self.height/2)
end

return Shot

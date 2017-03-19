local Util = require("util")
local Screen = require("screen")

local Shot = {}
Shot.__index = Shot

function Shot.create(location, sourcePart)
	local self = {}
	setmetatable(self, Shot)
	local imageName = "shot"
	self.image = love.graphics.newImage("res/images/"..imageName..".png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.x = location[1]
	self.y = location[2]
	self.angle = location[3]
	self.time = 0
	self.isDestroyed = false
	self.sourcePart = sourcePart
	return self
end

function Shot:getLocation()
	return self.x, self.y, self.angle
end

function Shot:update(dt, worldInfo)
	local dx, dy = Util.vectorComponents(500 * dt, self.angle + math.pi/2)
	self.x = self.x + dx
	self.y = self.y + dy
	self.time = self.time + dt
	if self.time > 5 then
		self.isDestroyed = true
	end

	local newObjects = {}
	for i, structure in ipairs(worldInfo[2].structures) do
		local partIndexHit = structure:getPartIndex(self.x, self.y)
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
		self.x,
		self.y,
		self.angle, 1, 1, self.width/2, self.height/2)
end

return Shot

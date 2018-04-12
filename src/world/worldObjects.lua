local WorldObjects = class()

function WorldObjects:__create(worldInfo, location, data)
	local l, physics = location, worldInfo.physics
	self.body = love.physics.newBody(physics, l[1], l[2], "dynamic")
	if l[3] then self.body:setAngle(l[3]) end
	if l[4] and l[5] then self.body:setLinearVelocity(l[4], l[5]) end
	if l[6] then self.body:setAngularVelocity(l[6]) end

	self.isDestroyed = false
end

function WorldObjects:postCreate(references)
end

function WorldObjects:destroy()
	self.body:destroy()
	self.isDestroyed = true
end

function WorldObjects:getLocation()
	local b = self.body
	local x, y = b:getPosition()
	local a = b:getAngle()
	local vx, vy = b:getLinearVelocity()
	local w = b:getAngularVelocity()
	return x, y, a, vx, vy, w
end

return WorldObjects

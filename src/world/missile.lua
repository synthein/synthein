local Util = require("util")
local Timer = require("timer")

local Missile = class(require("world/worldObjects"))

function Missile:__create(worldInfo, location, data, appendix)
	local imageName = "missile"
	local image = love.graphics.newImage("res/images/"..imageName..".png")
	local width = image:getWidth()
	local height = image:getHeight()
	self.drawData = {image, 0.4/width, -0.8/height, width/2, height/2}

	self.thrust = 10
	self.body:setLinearVelocity(location[4], location[5])
	self.body:setAngularVelocity(0)

	local physicsShape = love.physics.newRectangleShape(.4, .8)
	self.fixture = love.physics.newFixture(self.body, physicsShape)
	self.fixture:setSensor(true)
	self.fixture:setUserData(self)

	local visionArcRadius = 50
	local visionArcAngle = (60/180)*(math.pi)
	local x, y = Util.vectorComponents(visionArcRadius, (math.pi/2)-(visionArcAngle/2))
	local visionArcShape = love.physics.newPolygonShape(
		0, 0,
		x, y,
		-x, y
	)

	self.target = nil
	self.visionArc = love.physics.newFixture(self.body, visionArcShape, 0)
	self.visionArc:setUserData({
		collision = function(_, targetFixture)
			if not self.target then
				self.target = targetFixture:getBody()
			end
		end,
		draw = function() end,
	})
	self.visionArc:setSensor(true)

	self.timer = Timer(15)
	self.firstContact = true
	self.sourcePart = data
	self.startLocation = location
end

function Missile:postCreate(references)
	local team, time = unpack(self.sourcePart)
	self.team = team
	self.timer:time(time)
end

function Missile:type()
	return "missile"
end

function Missile:getSaveData(references)
	local part = self.sourcePart
	local x, y = unpack(part.location)
	local structure = part.fixture:getBody():getUserData()
	structure = references[structure]
	return {self.timer:time(), structure, x, y}
end

function Missile:collision(fixture)
	if fixture ~= self.sourcePart.fixture and self.firstContact then
		local object = fixture:getUserData()
		object:damage(fixture, 10)
		self:destroy()
		self.firstContact = false --this is needed because of bullet body physics
	end
end

function Missile:update(dt)
	if self.timer:ready(dt) then
		self:destroy()
	end

	if self.target then
		local missileX, missileY = self.body:getPosition()
		local targetX, targetY = self.target:getPosition()
		local angle = Util.vectorAngle(targetX - missileX, targetY - missileY)
		local angleToTarget = (-self.body:getAngle() + angle + math.pi/2) % (2*math.pi) - math.pi
		local sign = Util.sign(angleToTarget)

		self.body:applyTorque(sign)
	end

	self.body:applyForce(Util.vectorComponents(self.thrust, self.body:getAngle() + math.pi/2))

	return {}
end

-- Debug
function Missile:draw()
	local x, y, angle = self:getLocation():getXYA()
	local data = self.drawData
	love.graphics.draw(data[1], x, y, angle, data[2], data[3], data[4], data[5])

	love.graphics.setLineWidth(0.05)

	love.graphics.polygon('line', self.body:getWorldPoints(self.visionArc:getShape():getPoints()))
end
-- End debug.

return Missile

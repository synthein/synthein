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

	self.physicsShape = love.physics.newRectangleShape(.2, .2)
	self.fixture = love.physics.newFixture(self.body, self.physicsShape)
	self.fixture:setSensor(true)
	self.fixture:setUserData(self)

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
		object:damage(fixture, 1)
		self:destroy()
		self.firstContact = false --this is needed because of bullet body physics
	end
end

function Missile:update(dt)
	if self.timer:ready(dt) then
		self:destroy()
	end

	self.body:applyForce(Util.vectorComponents(self.thrust, self.body:getAngle() + math.pi/2))

	return {}
end

return Missile

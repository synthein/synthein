local Part = require("shipparts/part")
local Screen = require("screen")

local Engine = {}
Engine.__index = Engine
setmetatable(Engine, Part)

Engine.rotationTable = {
	{ 1, 1}, --  x
	{ 1, 2}, --  y
	{-1, 1}, -- -x
	{-1, 2}} -- -y

Engine.directionTable = {
	{-1, 2, 1, 1}, -- -y,  x	90
	{-1, 1,-1, 2}, -- -x, -y	180
	{ 1, 2,-1, 1}, --  y, -x	270
	{ 1, 1, 1, 2}} --  x,  y	0

function Engine.create(world, x, y)
	local self = Part.create()
	setmetatable(self, Engine)

	self.image = love.graphics.newImage("res/images/engine.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.isActive = false
	self.imageActive = love.graphics.newImage("res/images/engineActive.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	self.thrust = 250

	return self
end

function Engine:update(dt, partsInfo, location, locationSign, orientation)
	if partsInfo.engines then
		local body = partsInfo.body
		local engines = partsInfo.engines
		local r = Engine.rotationTable[orientation]
		local rotation = r[1]*locationSign[r[2]]
		on = engines[orientation] + engines[7]*rotation

		if on > 0 then
			self.isActive = true
		else
			self.isActive = false
		end
--[[

function Util.vectorAngle(x, y)
	local t = math.atan2(y, x)
	return t
end

function Util.vectorComponents(r, angle)
	local x = r * math.cos(angle)
	local y = r * math.sin(angle)
	return x, y
end

function Util.computeAbsCoords(x, y, angle)
	local r = Util.vectorMagnitude(x, y)
	local t = Util.vectorAngle(x, y)
	return Util.vectorComponents(r, t + angle)
end


	x, y = Util.computeAbsCoords(
		self.partCoords[index].x*self.PARTSIZE,
		self.partCoords[index].y*self.PARTSIZE,
		self.body:getAngle())
	orient = self.partOrient[index]
	return self.body:getX() + x, self.body:getY() + y,
		   self.body:getAngle() + (orient - 1) * math.pi/2
				% (2*math.pi)
end
--]]


		if self.isActive then
			d = Engine.directionTable[orientation]
			local l = partsInfo.locationInfo[1]
			local directionX = partsInfo.locationInfo[2][1]
			local directionY = partsInfo.locationInfo[2][2]
			a = {directionX, directionY}
			local x = (location[1] * directionX - location[2] * directionY) * 20 + l[1]
			local y = (location[1] * directionY + location[2] * directionX) * 20 + l[2]
			local appliedForceX = d[1] * a[d[2]]
			local appliedForceY = d[3] * a[d[4]]
			local Fx = appliedForceX * self.thrust
			local Fy = appliedForceY * self.thrust
			local body = engines[8]
			body:applyForce(Fx, Fy, x, y)
		end
	end
end

function Engine:draw(x, y, angle)
	local image
	if self.isActive then
		image = self.imageActive
		self.width = self.image:getWidth()
		self.height = self.image:getHeight()

	else
		image = self.image
		self.width = self.image:getWidth()
		self.height = self.image:getHeight()

	end
	Screen.draw(
		image,
		x,
		y,
		angle, 1, 1, self.width/2, self.height/2)
end

return Engine

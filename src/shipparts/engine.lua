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

	self.imageInactive = love.graphics.newImage("res/images/engine.png")
	self.imageActive = love.graphics.newImage("res/images/engineActive.png")
	self.image = self.imageInactive
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.isActive = false

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	self.thrust = 250

	return self
end

function Engine:update(dt, partsInfo, location, locationSign, orientation)
	self:setLocation(location, partsInfo.locationInfo, orientation)
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
	else
		self.isActive = false
	end
	
	if self.isActive then
		self.image = self.imageActive
	else
		self.image = self.imageInactive
	end
end

return Engine

local Util = require("util")

local Engine = {}
Engine.__index = Engine
setmetatable(Engine, Part)

Engine.orientationVectors = {
	{ 0,  1},
	{-1,  0},
	{ 0, -1},
	{ 1,  0}}

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

function Engine.create(engineType, thrust, torque)
	local self = {}
	setmetatable(self, Engine)

	self.isActive = false
	self.thrust = thrust
	if engineType == 1 then self.torque = torque end
	self.engineType = engineType

	return self
end

function Engine:update(part, enginesInfo)
	local body = part.fixture:getBody()

	if part.location and body and enginesInfo then
		local angle = (part.location[3] - 1) * math.pi/2 + body:getAngle()
		
		local fx, fy
		if self.engineType == 1 then
			fx = enginesInfo[6]
			fy = enginesInfo[5]
			if enginesInfo[5] == 0 and enginesInfo[6] == 0
					and enginesInfo[7] == 0 then
				on = 0
			else
				on = 1
			end
		elseif self.engineType == 2 then
			local r = Engine.rotationTable[part.location[3]]
			local rotation = r[1] * Util.sign(part.location[r[2]])
			on = enginesInfo[part.location[3]] + enginesInfo[7] * rotation
			fx, fy = unpack(Engine.orientationVectors[part.location[3]])
		end

		if on > 0 then
			self.isActive = true
		else
			self.isActive = false
		end
		
		if self.isActive then
			fx, fy = body:getWorldVector(fx, fy)
			local x, y = unpack(part.location)
			x, y = body:getWorldPoints(x, y)
			body:applyForce(fx * self.thrust, fy * self.thrust, x, y)

			if self.torque then
				body:applyTorque(enginesInfo[7] * self.torque)
			end
		end
	else
		self.isActive = false
	end

	return self.isActive
end

return Engine

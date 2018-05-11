local StructureMath = require("world/structureMath")
local Util = require("util")

local Engine = class()

function Engine:__create(engineType, thrust, torque)
	self.thrust = thrust
	if engineType == 1 then self.torque = torque end
	self.engineType = engineType
	-- Type
	-- 1: Found in playerBlock and aiBlock and is an all direction engine
	-- 2: Found in engineBlock is a single direction engine.

	return self
end

function Engine:update(part, enginesInfo)
	local body = part.fixture:getBody()
	local x, y, orientation = unpack(part.location)
	local active, fx, fy

	if not enginesInfo then
		return false
	end

	if self.engineType == 1 then
		if enginesInfo[5] == 0 and
		   enginesInfo[6] == 0 and
		   enginesInfo[7] == 0 then
			active = false
		else
			-- Set local force direction
			fx = enginesInfo[6]
			fy = enginesInfo[5]
			active = true
		end
	elseif self.engineType == 2 then
		-- Determine if engine is pointing in a helpful direction.
		local rotationTable = {x, y, -x, -y}
		local rotation = Util.sign(rotationTable[orientation])
		active = 0 < (enginesInfo[orientation] + enginesInfo[7] * rotation)
		-- Determine local force direction
		fx, fy = unpack(StructureMath.addUnitVector({0, 0}, orientation))
	end

	if active then
		-- Applying the forces and the torque
		fx, fy = body:getWorldVector(fx, fy)
		x, y = body:getWorldPoints(x, y)
		body:applyForce(fx * self.thrust, fy * self.thrust, x, y)

		if self.torque then
			body:applyTorque(enginesInfo[7] * self.torque)
		end
	end

	return active
end

return Engine

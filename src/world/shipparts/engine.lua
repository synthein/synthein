local StructureMath = require("world/structureMath")
local Util = require("util")

local Engine = class()

function Engine:__create(engineType, thrust, torque)
	self.thrust = thrust
	if engineType == 1 then self.torque = torque end
	self.engineType = engineType

	self.isActive = false
	-- Type
	-- 1: Found in playerBlock and aiBlock and is an all direction engine
	-- 2: Found in engineBlock is a single direction engine.
end

function Engine:getIsActive()
	return function() return self.isActive end
end

function Engine.process(orders)
	local perpendicular = 0
	local parallel = 0
	local rotate = 0

	for _, order in ipairs(orders) do
		if order == "forward" then parallel = parallel + 1 end
		if order == "back" then parallel = parallel - 1 end
		if order == "strafeLeft" then perpendicular = perpendicular - 1 end
		if order == "strafeRight" then perpendicular = perpendicular + 1 end
		if order == "right" then rotate = rotate - 1 end
		if order == "left" then rotate = rotate + 1 end
	end

	local controlTable = {0, 0, 0, 0, parallel, perpendicular, rotate}

	if parallel > 0 then
		controlTable[1] = 1
	elseif parallel < 0 then
		controlTable[3] = 1
	end

	if perpendicular > 0 then
		controlTable[4] = 1
	elseif perpendicular < 0 then
		controlTable[2] = 1
	end

	return controlTable
end

function Engine:update(body, location, controlTable)
	local x, y, orientation = unpack(location)
	local active, fx, fy

	if not controlTable then
		return false
	end

	if self.engineType == 1 then
		if controlTable[5] == 0 and
		   controlTable[6] == 0 and
		   controlTable[7] == 0 then
			active = false
		else
			-- Set local force direction
			fx = controlTable[6]
			fy = controlTable[5]
			active = true
		end
	elseif self.engineType == 2 then
		-- Determine if engine is pointing in a helpful direction.
		local rotationTable = {x, y, -x, -y}
		local rotation = Util.sign(rotationTable[orientation])
		active = 0 < (controlTable[orientation] + controlTable[7] * rotation)
		-- Determine local force direction
		fx, fy = unpack(StructureMath.addUnitVector({0, 0}, orientation))
	end

	self.isActive = active
	if active then
		-- Applying the forces and the torque
		fx, fy = body:getWorldVector(fx, fy)
		x, y = body:getWorldPoints(x, y)
		body:applyForce(fx * self.thrust, fy * self.thrust, x, y)

		if self.torque then
			body:applyTorque(controlTable[7] * self.torque)
		end
	end

	return active
end

return Engine

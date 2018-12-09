local StructureMath = require("world/structureMath")
local Timer = require("timer")
local LocationTable = require("locationTable")

local Gun = class()

function Gun:__create()
	self.charged = true
	self.rechargeTimer = Timer(0.5)

	return self
end

function Gun:update(dt, shoot, structure, l)
	if not self.charged then
		if self.rechargeTimer:ready(dt) then
			self.charged = true
		end
	else
		if shoot then
			-- Check if there is a part one block infront of the gun.
			local x, y = unpack(StructureMath.addUnitVector(l, l[3]))
			local clear = not structure.gridTable:index(x, y)

			if clear then
				self.charged = false
				-- Spawn Shot
				local body = structure.body

				local partX, partY, angle = unpack(l)
				local x, y = body:getWorldPoints(partX, partY)
				angle = (angle - 1) * math.pi/2 + body:getAngle()
				local vx, vy = body:getLinearVelocityFromLocalPoint(partX, partY)
				local w = body:getAngularVelocity()

				local part = structure.gridTable:index(partX, partY)

				local location = LocationTable(x, y, angle, vx, vy, w)

				local shot = {"shot", location, part}
				table.insert(structure.events.create, shot)
			end
		end
	end
end

return Gun

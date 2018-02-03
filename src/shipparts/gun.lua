local Part = require("shipparts/part")
local StructureMath = require("structureMath")

local Gun = {}
Gun.__index = Gun
setmetatable(Gun, Part)

function Gun.create()
	local self = {}
	setmetatable(self, Gun)

	self.recharge = false
	self.rechargeTime = 0

	return self
end

function Gun:update(dt, shoot, part)
	if self.recharge then
		-- Recharge timer
		self.rechargeTime = self.rechargeTime + dt
		if self.rechargeTime > 0.5 then
			self.rechargeTime = 0
			self.recharge = false
		end
	else
		if shoot then
			local structure = part.fixture:getBody():getUserData()
			-- Check if there is a part one block infront of the gun.
			local l = part.location
			local x, y = unpack(StructureMath.addUnitVector(l, l[3]))
			local clear = not structure.gridTable:index(x, y)

			if clear then
				-- Start timer
				self.recharge = true
				-- Spawn Shot
				local shot = {"shots", {part:getWorldLocation()}, part}
				table.insert(structure.events.create, shot)
			end
		end
	end
end

return Gun

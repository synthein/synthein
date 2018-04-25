local StructureMath = require("world/structureMath")
local Timer = require("timer")

local Gun = {}
Gun.__index = Gun

function Gun.create()
	local self = {}
	setmetatable(self, Gun)

	self.charged = true
	self.rechargeTimer = Timer(0.5)

	return self
end

function Gun:update(dt, shoot, part)
	if not self.charged then
		if self.rechargeTimer:ready(dt) then
			self.charged = true
		end
	else
		if shoot then
			local structure = part.fixture:getBody():getUserData()
			-- Check if there is a part one block infront of the gun.
			local l = part.location
			local x, y = unpack(StructureMath.addUnitVector(l, l[3]))
			local clear = not structure.gridTable:index(x, y)

			if clear then
				self.charged = false
				-- Spawn Shot
				local shot = {"shots", part:getWorldLocation(), part}
				table.insert(structure.events.create, shot)
			end
		end
	end
end

return Gun

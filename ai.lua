local Util = require("util")

local AI = {}
AI.__index = AI

function AI.create(structure)
	local self = {}
	setmetatable(self, AI)

	self.ship = structure


	return self
end

function AI:update(dt, playerShip)
	local orders = {}
	local aiX, aiY , aiAngle = self.ship:getAbsPartCoords(1)
	local playerX, playerY = playerShip:getAbsPartCoords(1)
	local angle = Util.vectorAngle(playerX - aiX, playerY - aiY)
	angle = aiAngle - angle - math.pi/2
	if angle > math.pi then angle = angle - 2 * math.pi end
	if angle  < -math.pi/15 then
		table.insert(orders, "right")
	elseif angle > math.pi/15 then
		table.insert(orders, "left")
	else 
		table.insert(orders, "shoot")
	end
	if Util.vectorMagnitude(playerX - aiX, playerY - aiY) > 10 * 20 then
		table.insert(orders, "forward")
	end
	self.ship:command(orders)
	self.ship:update(dt)
end

function AI:draw(globalOffsetX, globalOffsetY)
	self.Ship:draw(globalOffsetX, globalOffsetY)
end

return AI


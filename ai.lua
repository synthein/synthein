local Util = require("util")

local AI = {}
AI.__index = AI

function AI.create(structure, team)
	local self = {}
	setmetatable(self, AI)

	self.ship = structure
	self. team = team

	return self
end

function AI:update(dt, playerShip, target)
	local orders = {}
	local aiX = self.ship.body:getX()
	local aiY = self.ship.body:getY()
	local aiAngle = self.ship.body:getAngle()
	local targetX, targetY, angle
	if target then
		targetX = target.body:getX()
		targetY = target.body:getY()
		angle = Util.vectorAngle(targetX - aiX, targetY - aiY)
		angleTotarget = (aiAngle - angle + math.pi/2) % (2*math.pi) - math.pi
	end
	local playerX = playerShip.body:getX()
	local playerY = playerShip.body:getY()
	local angle = Util.vectorAngle(playerX - aiX, playerY - aiY)
	angleToPlayer = (aiAngle - angle + math.pi/2) % (2*math.pi) - math.pi
	if self.team == 1 and 
	   Util.vectorMagnitude(playerX - aiX, playerY - aiY) > 10 * 20 then
		if angleToPlayer < -math.pi/10 then
			table.insert(orders, "right")
		elseif angleToPlayer > math.pi/10 then
			table.insert(orders, "left")
		else
			table.insert(orders, "forward")
		end
	elseif target then
		if angleTotarget  < -math.pi/20 then
			table.insert(orders, "right")
		elseif angleTotarget > math.pi/20 then
			table.insert(orders, "left")
		else 
			table.insert(orders, "shoot")
		end
		if self.team ~= 1 then
			if Util.vectorMagnitude(targetX - aiX, targetY - aiY) > 15 * 20 then
				table.insert(orders, "forward")
			elseif Util.vectorMagnitude(targetX - aiX, targetY - aiY) < 10 * 20 then
				table.insert(orders, "backward")
			end
		end
	end
	self.ship:command(orders)
	self.ship:update(dt)
end

function AI:draw()
	self.Ship:draw()
end

return AI


local Util = require("util")

local AI = {}
AI.__index = AI

AI.teamHostility = {{false, true},
					{true, false}}

function AI.create(team)
	local self = {}
	setmetatable(self, AI)

	self.team = team
	self.follow = true

	return self
end

function AI:getOrders(location, aiData)
	local aiX = location[1]
	local aiY = location[2]
	local aiAngle = location[3]
	local playerX = nil
	local playerY = nil
	local targetX = nil
	local targetY = nil
	local targetM = nil
	local angle = nil
	local angle = nil
	local angleToTarget = nil
	local angleToPlayer = nil
	if aiData[1] then
		for i, team in ipairs(aiData[1]) do
			if AI.teamHostility[self.team][i] then
				for j, enemy in ipairs(aiData[1][i]) do
					if targetX and targetY and targetM then
						local m = Util.vectorMagnitude(enemy[1] - location[1], enemy[2] - location[2])
						if targetM > m then
							targetX = enemy[1]
							targetY = enemy[2]
							targetM = m
						end
					else
						targetX = enemy[1]
						targetY = enemy[2]
						targetM = Util.vectorMagnitude(enemy[1] - location[1], enemy[2] - location[2])
					end
				end
			elseif self.team == i then
				for j, ally in ipairs(aiData[1][i]) do
					if ally[3] then
						playerX = ally[1]
						playerY = ally[2]
					end
				end
			end
		end
	end
	if targetX and targetY then
		angle = Util.vectorAngle(targetX - aiX, targetY - aiY)
		angleToTarget = (-aiAngle + angle + math.pi/2) % (2*math.pi) - math.pi
	end
	if playerX and playerY then
		angle = Util.vectorAngle(playerX - aiX, playerY - aiY)
		angleToPlayer = (-aiAngle + angle + math.pi/2) % (2*math.pi) - math.pi
	end
	local orders = {}
	if self.team == 1 and playerX and playerY and self.follow and
	   Util.vectorMagnitude(playerX - aiX, playerY - aiY) > 20 * 20 then
		if angleToPlayer < -math.pi/10 then
			table.insert(orders, "right")
		elseif angleToPlayer > math.pi/10 then
			table.insert(orders, "left")
		else
			table.insert(orders, "forward")
		end
	elseif angleToTarget then
		if angleToTarget  < -math.pi/20 then
			table.insert(orders, "right")
		elseif angleToTarget > math.pi/20 then
			table.insert(orders, "left")
		else 
			table.insert(orders, "shoot")
		end
		if self.team ~= 1 then
			if Util.vectorMagnitude(targetX - aiX, targetY - aiY) > 15 * 20 and 
				self.follow then
				table.insert(orders, "forward")
			elseif Util.vectorMagnitude(targetX - aiX, targetY - aiY) < 10 * 20 then
				table.insert(orders, "backward")
			end
		end
	end
	return orders
end

function AI:getMenu()
	return {1, 0, 0, 1, 0, 0}
end

function AI:runMenu(i)
	if i == 1 then
		self.follow = true
	elseif i == 4 then
		self.follow = false
	end
end

function AI:update(dt)
end

function AI:draw()
end

return AI


local Util = require("util")

local AI = {}
AI.__index = AI

AI.teamHostility = {{false, true},
					{true, false}}

AI.defaultLeaders = {}

function AI.create(team)
	local self = {}
	setmetatable(self, AI)

	self.team = team
	self.follow = true
	self.leader = AI.defaultLeaders[team]

	return self
end

function AI:getOrders(location, physics)
	local aiX = location[1]
	local aiY = location[2]
	local aiAngle = location[3]

	AI.callbackData.objects = {}
	physics:queryBoundingBox(aiX - 1000, aiY - 1000, 
							 aiX + 1000, aiY + 1000, 
							 AI.fixtureCallback)

	local targetX = nil
	local targetY = nil
	local targetM = nil
	local angleToTarget = nil
	local angle = nil
	local active = true
	local orders = {}
	if self.leader and self.follow then
		targetX, targetY = self.leader:getLocation()
		angle = Util.vectorAngle(targetX - aiX, targetY - aiY)
		angleToTarget = (-aiAngle + angle + math.pi/2) % (2*math.pi) - math.pi
	   if Util.vectorMagnitude(targetX - aiX, targetY - aiY) > 20 * 20 then
			if angleToTarget < -math.pi/10 then
				table.insert(orders, "right")
			elseif angleToTarget > math.pi/10 then
				table.insert(orders, "left")
			else
				table.insert(orders, "forward")
			end
			active = false
		end
	end

	if active then
		targetX = nil
		targetY = nil
		angleToTarget = nil
		if #AI.callbackData.objects > 0 then
			for i, object in ipairs(AI.callbackData.objects) do
				if object.getTeam and 
				   AI.teamHostility[self.team][object:getTeam()] then
					local eX, eY = object:getWorldLocation()
					if eX and eY then
						if targetX and targetY and targetM then
							local m = Util.vectorMagnitude(eX - location[1],
														   eY - location[2])
							if targetM > m then
								targetX = eX
								targetY = eY
								targetM = m
							end
						else
							targetX = eX
							targetY = eY
							targetM = Util.vectorMagnitude(eX - location[1],
														   eY - location[2])
						end
					end
				end
			end
		end
		if targetX and targetY then
			angle = Util.vectorAngle(targetX - aiX, targetY - aiY)
			angleToTarget = (-aiAngle + angle + math.pi/2) % (2*math.pi) - math.pi
		end

		if angleToTarget then
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
	end
	return orders
end

AI.callbackData = {objects = {}}

function AI.fixtureCallback(fixture)
	if not fixture:isSensor() then
		table.insert(AI.callbackData.objects, fixture:getUserData())
	end
	return true
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


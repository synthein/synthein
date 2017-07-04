local Util = require("util")

local AI = {}
AI.__index = AI

function AI.create(team)
	local self = {}
	setmetatable(self, AI)

	self.team = team
	self.follow = true

	return self
end

function AI:getOrders(location, worldInfo, leader, body)
	local physics = worldInfo.physics
	local teamHostility = worldInfo.teamHostility
	local aiX = location[1]
	local aiY = location[2]
	local aiAngle = location[3]
	local aiAngleVol = location[6]

	AI.callbackData.objects = {self = body}
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
	if leader and self.follow then
		targetX, targetY = leader:getLocation()
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
				   teamHostility:test(self.team, object:getTeam()) then
					local eX, eY = object:getWorldLocation()
					if eX and eY then
						local m = Util.vectorMagnitude(eX - location[1],
													   eY - location[2])
						if not (targetX and targetY and targetM) or targetM > m then
							targetX = eX
							targetY = eY
							targetM = m
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
			local sign = Util.sign(angleToTarget)
			if sign * angleToTarget > sign * aiAngleVol /10 then
				if sign == 1 then
					table.insert(orders, "left")
				elseif sign == -1 then
					table.insert(orders, "right")
				end
			else
				AI.callbackData.ray = {self, teamHostility, true}
				physics:rayCast(aiX, aiY, targetX, targetY, AI.RayCastCallback)
				if AI.callbackData.ray[3] then
					table.insert(orders, "shoot")
				end
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

AI.callbackData = {objects = {}, ray = {}}

function AI.fixtureCallback(fixture)
	local body = fixture:getBody()
	if not fixture:isSensor() and AI.callbackData.objects.self ~= body then
		table.insert(AI.callbackData.objects, fixture:getUserData())
	end
	return true
end

function AI.RayCastCallback(fixture, x, y, xn, yn, fraction)
	local ray = AI.callbackData.ray
	local structure = fixture:getBody():getUserData()
	if structure and structure.corePart then
		local team = structure.corePart:getTeam()
		if not ray[2]:test(ray[1].team, team) then
			if not structure.corePart.ai or
					structure.corePart.ai ~= ray[1] then
				AI.callbackData.ray[3] = false
				return 0
			end
		end
	end
	return -1
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


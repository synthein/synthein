local Util = require("util")

local AI = class()

function AI:__create(team)
	self.team = team
	self.follow = true
end

function AI:getOrders(worldInfo, leader, body)
	local physics = worldInfo.physics
	local teamHostility = worldInfo.teamHostility
	local aiX, aiY = body:getPosition()
	local aiAngle = body:getAngle()
	local aiXV, aiYV = body:getLinearVelocity()
	local aiAngleVol = body:getAngularVelocity()
	local target, leaderX, leaderY, leaderMSq
	local leaderFollow = false
	if leader and self.follow then
		leaderX, leaderY = leader:getLocation():getXY()
		local dx = leaderX - aiX
		local dy = leaderY - aiY
		leaderMSq = (dx * dx) + (dy * dy)
		leaderFollow = leaderMSq > 20 * 20
	end

	local shoot = true
	if leaderFollow then
		target = {leaderX, leaderY, leaderMSq}
		shoot = false
	else
		local objects = {}
		local function fixtureCallback(fixture)
			local objectBody = fixture:getBody()
			if not fixture:isSensor() and objectBody ~= body then
				table.insert(objects, fixture:getUserData())
			end
			return true
		end

		physics:queryBoundingBox(aiX - 500, aiY - 500, aiX + 500, aiY + 500,
								 fixtureCallback)

		-- Search for any enemies.
		if #objects > 0 then
			local targetMSq = nil
			for _, object in ipairs(objects) do
				-- Look for core blocks.
				if object.getTeam and
				   teamHostility:test(self.team, object:getTeam()) then
					local eX, eY = object:getWorldLocation():getXY()
					if eX and eY then
						local dx = eX - aiX
						local dy = eY - aiY
						local mSq = (dx * dx) + (dy * dy)
						if not targetMSq or targetMSq > mSq then
							target = {eX, eY, mSq}
							targetMSq = mSq
						end
					end
				end
			end
		end
	end

	if not target then
		return {}
	end

	local targetX, targetY, distanceToTargetSq = unpack(target)
	local orders = {}

	-- Aim the ship.
	local angle = Util.vectorAngle(targetX - aiX, targetY - aiY)
	local angleToTarget = (-aiAngle + angle + math.pi/2) % (2*math.pi) - math.pi
	local sign = Util.sign(angleToTarget)

	if sign * angleToTarget > sign * aiAngleVol /10 then
		if sign == 1 then
			table.insert(orders, "left")
		elseif sign == -1 then
			table.insert(orders, "right")
		end
	else
		-- Move forward or backward to adjust distance to enemy.
		local distanceSq = distanceToTargetSq - 15*15
		local velocitySq = (aiXV * aiXV) + (aiYV * aiYV)
		if sign * distanceSq > sign * velocitySq * 10 then
			if sign == 1 then
			table.insert(orders, "forward")
			elseif sign == -1 then
			table.insert(orders, "backward")
			end
		end

		if shoot then
			local hit = true
			local function RayCastCallback(fixture, _, _, _, _, _) --(fixture, x, y, xn, yn, fraction)
				local structure = fixture:getBody():getUserData()
				if structure and structure.corePart then
					local team = structure.corePart:getTeam()
					if not teamHostility:test(self.team, team) then
						if not structure.corePart.ai or
								structure.corePart.ai ~= self then
							hit = false
							return 0
						end
					end
				end
				return -1
			end

			physics:rayCast(aiX, aiY, targetX, targetY, RayCastCallback)
			if hit then
				table.insert(orders, "shoot")
			end
		end
	end

	return orders
end

function AI:getMenu()
	return {1, 0, 0, 1, 0, 0}, {"Follow", "", "", "Stay", "", ""}
end

function AI:runMenu(i)
	if i == 1 then
		self.follow = true
	elseif i == 4 then
		self.follow = false
	end
end

return AI

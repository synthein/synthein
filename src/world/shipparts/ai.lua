local vector = require("vector")

local AI = class()

function AI:__create(team)
	self.team = team
	self.follow = true
end

function AI:getOrders(worldInfo, leader, aiBody, bodyList)
	local physics = worldInfo.physics
	local teamHostility = worldInfo.teamHostility
	local aiX, aiY = aiBody:getPosition()
	local aiAngle = aiBody:getAngle()
	local aiXV, aiYV = aiBody:getLinearVelocity()
	local aiAngleVol = aiBody:getAngularVelocity()
	local target, leaderX, leaderY, leaderVX, leaderVY, leaderMSq

	local leaderFollow = false
	if leader then
		leaderX, leaderY = leader:getLocation():getXY()
		leaderVX, leaderVY = leader.body:getLinearVelocity()
		target = {leaderX, leaderY, leaderVX, leaderVY}

		if self.follow then
			local dx = leaderX - aiX
			local dy = leaderY - aiY
			leaderMSq = (dx * dx) + (dy * dy)
			leaderFollow = leaderMSq > 30 * 30
			target[5] = leaderMSq
		end
	end

	local shoot = false
	if not leaderFollow then
		-- Search for any enemies.
		if next(bodyList) ~= nil then
			local targetMSq = nil
			for body, fixtures in pairs(bodyList) do
				local object = body:getUserData()
				-- Look for core blocks.
				if object and object.getTeam and
				   teamHostility:test(self.team, object:getTeam()) then
					local eX, eY = body:getPosition()
					if eX and eY then
						local dx = eX - aiX
						local dy = eY - aiY
						local mSq = (dx * dx) + (dy * dy)
						if not targetMSq or targetMSq > mSq then
							shoot = true
							local vx, vy = body:getLinearVelocity()
							target = {eX, eY, vx, vy, mSq}
							targetMSq = mSq
						end
					end
				end
			end
		end
	end

	local orders = {}

	local targetX, targetY, targetVX, targetVY, distanceToTargetSq, angle

	local rdx, rdy, rvx, rvy
	if target then
		targetX, targetY, targetVX, targetVY, distanceToTargetSq = unpack(target)

		rdx, rdy = aiBody:getLocalVector(targetX - aiX, targetY - aiY)
		rvx, rvy = aiBody:getLocalVector(targetVX - aiXV, targetVY - aiYV)
		angle = vector.angle(targetX - aiX, targetY - aiY)
	else
		rdx, rdy, rvx, rvy, angle = 0, 0, 0, 0, 0
	end

	local pidX = rdx + 2 * rvx
	if 2 < pidX then
		table.insert(orders, "strafeRight")
	elseif -2 > pidX then
		table.insert(orders, "strafeLeft")
	end

	-- The -15 is the simplest way to add space between the two ships.
	local pidY = (rdy - 15) + 2 * rvy
	if 5 < pidY then
		table.insert(orders, "forward")
	elseif -5 > pidY then
		table.insert(orders, "back")
	end

	-- Aim the ship.
	local angleToTarget = (-aiAngle + angle + math.pi/2) % (2*math.pi) - math.pi
	local sign = vector.sign(angleToTarget)

	if sign * angleToTarget > sign * aiAngleVol /10 then
		if sign == 1 then
			table.insert(orders, "left")
		elseif sign == -1 then
			table.insert(orders, "right")
		end
	else
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

function AI:update()
end

return AI

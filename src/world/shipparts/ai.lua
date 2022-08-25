local vector = require("vector")
local Location = require("world/location")

local AI = class()

function AI:__create(team)
	self.team = team
	self.follow = true
end

function AI:getOrders(worldInfo, leader, aiBody, bodyList)


	--Check for Leader + follow
		--Do something for fomation location

		--Get post


	--Compute relative Components









	local teamHostility = worldInfo.teamHostility

	local aiX, aiY, aiA, aiXV, aiYV, aiAV =
		Location.bodyCenter6(aiBody)

	local target, leaderX, leaderY, leaderA, leaderVX, leaderVY, leaderMSq

	local leaderFollow = false
	if leader and self.follow then
		leaderX, leaderY, leaderA = leader:getLocation():getXYA()
		leaderVX, leaderVY = leader.body:getLinearVelocity()
		target = {leaderX, leaderY, leaderVX, leaderVY}

		local dx = leaderX - aiX
		local dy = leaderY - aiY
		leaderMSq = (dx * dx) + (dy * dy)
		leaderFollow = leaderMSq > 30 * 30
		target[5] = leaderMSq
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

	local targetX, targetY
	local destXV, destYV, destAV

	local rdx, rdy, rvx, rvy, rda, rva
	if target then
		local targetVX, targetVY, distanceToTargetSq
		targetX, targetY, targetVX, targetVY, distanceToTargetSq = unpack(target)

		rdx, rdy = aiBody:getLocalVector(targetX - aiX, targetY - aiY)

		-- The -15 is the simplest way to add space between the two ships.
		--rdy = rdy - 15


		local d = 15
		local dsq = d * d
		local m = 1 - dsq/distanceToTargetSq

		rdx = rdx * m
		rdy = rdy * m

		local angle
		local pi = math.pi

		if shoot then
			angle = vector.angle(targetX - aiX, targetY - aiY) + pi/2
		else
			angle = leaderA + pi
		end
		rda = (angle - aiA) % (2*pi) - pi

		destXV, destYV, destAV = targetVX, targetVY, 0

	else
		rdx, rdy, rda = 0, 0, 0
		destXV, destYV, destAV = 0, 0, 0
	end

	rvx, rvy = aiBody:getLocalVector(destXV - aiXV, destYV - aiYV)
	rva = destAV - aiAV



	--Filght Controls
	local pidX = rdx + 2 * rvx
	if 2 < pidX then
		table.insert(orders, "strafeRight")
	elseif -2 > pidX then
		table.insert(orders, "strafeLeft")
	end

	local pidY = rdy + 2 * rvy
	if 5 < pidY then
		table.insert(orders, "forward")
	elseif -5 > pidY then
		table.insert(orders, "back")
	end

	local pidA = rda + rva / 10
	if pidA > 0.05 then
		table.insert(orders, "left")
	elseif pidA < -0.05 then
		table.insert(orders, "right")
	end

	--Shooting Logic
	local ontarget = -0.1 < rda and rda < 0.1
	if ontarget and shoot then
		--Safety Check before shooting
		local hit = false
		local min = 1
		local function RayCastCallback(fixture, x, y, xn, yn, fraction)
			local body = fixture:getBody()
			local object = body:getUserData()
			local hasTeam = object and object.getTeam
			if body ~= aiBody and hasTeam and fraction < min then
				min = fraction
				local team = object:getTeam()
				hit = teamHostility:test(self.team, team)
			end
			return -1
		end
		worldInfo.physics:rayCast(aiX, aiY, targetX, targetY, RayCastCallback)
		if hit then
			table.insert(orders, "shoot")
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

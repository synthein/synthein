local vector = require("vector")
local Location = require("world/location")

local AI = class()

function AI:__create(team)
	self.team = team
	self.follow = true
end

function AI:getOrders(worldInfo, leader, aiBody, bodyList)
	local teamHostility = worldInfo.teamHostility
	local aiX, aiY, aiA, aiXV, aiYV, aiAV = Location.bodyCenter6(aiBody)

	--Spacing variables
	local d = 15
	local dsq = d * d
	local m = 1

	--Cordination Logic
	local destination
	local leaderFollow
	if leader and self.follow then
		leaderBody = leader.body
		local dx, dy = leaderBody:getLocalPoint(aiX, aiY)
		local leaderMSq = (dx * dx) + (dy * dy)

		leaderFollow = leaderMSq > 30 * 30

		--TODO add formation logic here
		destination = {Location.bodyCenter6(leaderBody)}
		m = 1 - dsq/leaderMSq
	else
		--TODO logic for ai post/home/station
	end

	local shoot = false
	local targetMSq = nil
	local target
	-- Loop through visable things
	if next(bodyList) ~= nil then
		for body, fixtures in pairs(bodyList) do
			local object = body:getUserData()
			-- Look for structures.
			if object and object.type() == "structure" then
				local dx, dy = body:getLocalPoint(aiX, aiY)
				local mSq = (dx * dx) + (dy * dy)

				--TODO add spacing logic here.

				if teamHostility:test(self.team, object:getTeam()) then
					if not targetMSq or targetMSq > mSq then
						shoot = true
						target = {Location.bodyCenter6(body)}
						targetMSq = mSq
					end
				end
			end
		end
	end

	local pi = math.pi

	--Change Logic if enemy is around
	if target then
		local angle = vector.angle(target[1] - aiX, target[2] - aiY) - pi/2

		if destination and leaderFollow then
			--Keep travel information just aim at enemy
			destination[3] = angle
		else
			--Follow enemy if bored
			destination = target
			target[3] = angle
			target[6] = 0
			m = 1 - dsq/targetMSq
		end
	end

	--Prepare Relative Values
	local rdx, rdy, rvx, rvy, rda, rva
	if destination then
		rdx = (destination[1] - aiX) * m
		rdy = (destination[2] - aiY) * m
		rda = (destination[3] - aiA + pi) % (2*pi) - pi
		rvx =  destination[4] - aiXV
		rvy =  destination[5] - aiYV
		rva =  destination[6] - aiAV
	else
		rdx, rdy, rda = 0, 0, 0
		rvx, rvy, rva = -aiXV, -aiYV, -aiAV
	end
	rdx, rdy = aiBody:getLocalVector(rdx, rdy)
	rvx, rvy = aiBody:getLocalVector(rvx, rvy)


	--Filght Controls
	local orders = {}

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
		worldInfo.physics:rayCast(aiX, aiY, target[1], target[2], RayCastCallback)
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

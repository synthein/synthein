local vector = require("vector")
local Location = require("world/location")

local Drone = class()

function Drone:__create(team)
	self.team = team
	self.follow = true
end

function Drone:getOrders(worldInfo, leader, droneBody, bodyList)
	local teamHostility = worldInfo.teamHostility
	local droneX, droneY, droneA, droneXV, droneYV, droneAV = Location.bodyCenter6(droneBody)

	--Spacing variables
	local d = 15
	local dsq = d * d
	local m = 1

	--Cordination Logic
	local destination
	local leaderFollow
	if self.follow then
		if leader then
			leaderBody = leader.body
			local dx, dy = leaderBody:getLocalPoint(droneX, droneY)
			local leaderMSq = (dx * dx) + (dy * dy)

			leaderFollow = leaderMSq > 30 * 30

			--TODO add formation logic here
			destination = {Location.bodyCenter6(leaderBody)}
			m = 1 - dsq/leaderMSq
		end
	else
		local post = self.post
		if post then
			local x, y, a = unpack(post)
			destination = {x, y, a, 0, 0, 0}
		end
	end

	local shoot = false
	local targetMSq = nil
	local target

	local sepX, sepY = 0, 0
	-- Loop through visable things
	if next(bodyList) ~= nil then
		for body, fixtures in pairs(bodyList) do
			local object = body:getUserData()
			-- Look for structures.
			if object and object.type() == "structure" then
				local  dx,  dy = body:getPosition()
				local dvx, dvy = body:getLinearVelocity()

				dx = dx - droneX
				dy = dy - droneY
				dvx = dvx - droneXV
				dvy = dvy - droneYV

				local mSq = (dx * dx) + (dy * dy)
				local collisionMetric = (dx * dvx + dy * dvy) / mSq

				-- 0 is somewhat arbitrary it can be used to create a threshhold
				if collisionMetric < 0 then
					-- Constant is calibrated subject to change
					sepX = sepX + dx * 10 * collisionMetric
					sepY = sepY + dy * 10 * collisionMetric
				end

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
		local angle = vector.angle(target[1] - droneX, target[2] - droneY) - pi/2

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
		rdx = (destination[1] - droneX) * m + sepX
		rdy = (destination[2] - droneY) * m + sepY
		rda = (destination[3] - droneA + pi) % (2*pi) - pi
		rvx =  destination[4] - droneXV
		rvy =  destination[5] - droneYV
		rva =  destination[6] - droneAV
	else
		rdx, rdy, rda = 0, 0, 0
		rvx, rvy, rva = -droneXV, -droneYV, -droneAV
	end
	rdx,  rdy  = droneBody:getLocalVector(rdx,  rdy )
	rvx,  rvy  = droneBody:getLocalVector(rvx,  rvy )

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
			if body ~= droneBody and hasTeam and fraction < min then
				min = fraction
				local team = object:getTeam()
				hit = teamHostility:test(self.team, team)
			end
			return -1
		end
		worldInfo.physics:rayCast(droneX, droneY, target[1], target[2], RayCastCallback)
		if hit then
			table.insert(orders, "shoot")
		end
	end

	return orders
end

function Drone:getMenu()
	return {1, 1, 1}, {"Follow", "Return", "Stay"}
end

function Drone:runMenu(i, body)
	if i == 1 then
		self.follow = true
	elseif i == 2 then
		self.follow = false
	elseif i == 3 then
		self.follow = false
		self.post = {Location.bodyCenter3(body)}
	end
end

function Drone:update()
end

return Drone
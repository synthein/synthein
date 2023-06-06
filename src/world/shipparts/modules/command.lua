local Command = class()

function Command:__create()
	self.formationTimeout = 5
	self.formation = {
		["L5"] = {location = {-50, -50}, inuse = false, timeout = 0},
		["L4"] = {location = {-40, -40}, inuse = false, timeout = 0},
		["L3"] = {location = {-30, -30}, inuse = false, timeout = 0},
		["L2"] = {location = {-20, -20}, inuse = false, timeout = 0},
		["L1"] = {location = {-10, -10}, inuse = false, timeout = 0},
		["R1"] = {location = { 10, -10}, inuse = false, timeout = 0},
		["R2"] = {location = { 20, -20}, inuse = false, timeout = 0},
		["R3"] = {location = { 30, -30}, inuse = false, timeout = 0},
		["R4"] = {location = { 40, -40}, inuse = false, timeout = 0},
		["R5"] = {location = { 50, -50}, inuse = false, timeout = 0},
		[""  ] = {location = {  0, -50}, inuse = false, timeout = 0},
	}
	self.formationPriority = {
		"R1",
		"L1",
		"R2",
		"L2",
		"R3",
		"L3",
		"R4",
		"L4",
		"R5",
		"L5",
	}
end

function Command:checkin(assignment)
	self.formation[assignment].timeout = 0
	
	--TODO Logic for reassignment
	return assignment
end

function Command:getAssignment(id)
	--TODO id based assignment
	--TODO ship type based assignment
	for _, assignment in ipairs(self.formationPriority) do
		if not self.formation[assignment].inuse then
			self.formation[assignment].inuse = true
			return assignment
		end
	end
	return ""
end

function Command:getPosition(assignment)
	return self.formation[assignment].location
end

function Command:update(dt)
	for position, station in pairs(self.formation) do
		if station.inuse then
			station.timeout = station.timeout + dt
			if station.timeout > self.formationTimeout then
				station.timeout = 0
				station.inuse = false
			end
		end
	end
end

return Command

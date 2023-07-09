local Command = class()

function Command:__create()
	self.formationTimeout = 5
	
	self.availableFormations = {"travel", "combat"}
	self.activeFormation = self.availableFormations[1]
	
	--TODO move assignments to a separate table
	self.formations = {
		travel = {
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
		},
		combat = {
			["L5"] = {location = {-50,   0}, inuse = false, timeout = 0},
			["L4"] = {location = {-40,   0}, inuse = false, timeout = 0},
			["L3"] = {location = {-30,   0}, inuse = false, timeout = 0},
			["L2"] = {location = {-20,   0}, inuse = false, timeout = 0},
			["L1"] = {location = {-10,   0}, inuse = false, timeout = 0},
			["R1"] = {location = { 10,   0}, inuse = false, timeout = 0},
			["R2"] = {location = { 20,   0}, inuse = false, timeout = 0},
			["R3"] = {location = { 30,   0}, inuse = false, timeout = 0},
			["R4"] = {location = { 40,   0}, inuse = false, timeout = 0},
			["R5"] = {location = { 50,   0}, inuse = false, timeout = 0},
			[""  ] = {location = {  0, -50}, inuse = false, timeout = 0},
		},
	}
	--TODO old remove connections and delete
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
	self.assignmentPriority = {
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
	for _, assignment in ipairs(self.assignmentPriority) do
		if not self.formation[assignment].inuse then
			self.formation[assignment].inuse = true
			return assignment
		end
	end
	return ""
end

function Command:getPosition(assignment)
	local formations = self.formations
	local activeFormation = self.activeFormation
	local positions = formations[activeFormation]
	local position = positions[assignment]
	return position.location
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

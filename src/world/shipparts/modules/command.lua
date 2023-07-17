local Command = class()

function Command:__create()
	self.formationTimeout = 5
	
	self.availableFormations = {"travel", "combat"}
	self.activeFormation = self.availableFormations[1]
	
	self.assignments = {
		["L5"] = {inuse = false, timeout = 0, promotions = {"L4", "R4"}},
		["L4"] = {inuse = false, timeout = 0, promotions = {"L3", "R3"}},
		["L3"] = {inuse = false, timeout = 0, promotions = {"L2", "R2"}},
		["L2"] = {inuse = false, timeout = 0, promotions = {"L1", "R1"}},
		["L1"] = {inuse = false, timeout = 0, promotions = {}},
		["R1"] = {inuse = false, timeout = 0, promotions = {}},
		["R2"] = {inuse = false, timeout = 0, promotions = {"R1", "L1"}},
		["R3"] = {inuse = false, timeout = 0, promotions = {"R2", "L2"}},
		["R4"] = {inuse = false, timeout = 0, promotions = {"R3", "L3"}},
		["R5"] = {inuse = false, timeout = 0, promotions = {"R4", "L4"}},
		[""  ] = {inuse = false, timeout = 0, promotions = {"L5", "R5"}},
	}
	
	self.formations = {
		travel = {
			["L5"] = {-50, -50},
			["L4"] = {-40, -40},
			["L3"] = {-30, -30},
			["L2"] = {-20, -20},
			["L1"] = {-10, -10},
			["R1"] = { 10, -10},
			["R2"] = { 20, -20},
			["R3"] = { 30, -30},
			["R4"] = { 40, -40},
			["R5"] = { 50, -50},
			[""  ] = {  0, -50},
		},
		combat = {
			["L5"] = {-25,   0},
			["L4"] = {-20,   0},
			["L3"] = {-15,   0},
			["L2"] = {-10,   0},
			["L1"] = {- 5,   0},
			["R1"] = {  5,   0},
			["R2"] = { 10,   0},
			["R3"] = { 15,   0},
			["R4"] = { 20,   0},
			["R5"] = { 25,   0},
			[""  ] = {  0, -50},
		},
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
	for _, a in ipairs(self.assignments[assignment].promotions) do
		if not self.assignments[a].inuse then
			assignment = a
			self.assignments[a].inuse = true
			break
		end
	end

	self.assignments[assignment].timeout = 0
	
	return assignment
end

function Command:getAssignment(id)
	--TODO id based assignment
	--TODO ship type based assignment
	for _, assignment in ipairs(self.assignmentPriority) do
		if not self.assignments[assignment].inuse then
			self.assignments[assignment].inuse = true
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
	return position
end

function Command:update(dt)
	for assignment, assignmentTable in pairs(self.assignments) do
		if assignmentTable.inuse then
			assignmentTable.timeout = assignmentTable.timeout + dt
			if assignmentTable.timeout > self.formationTimeout then
				assignmentTable.timeout = 0
				assignmentTable.inuse = false
			end
		end
	end
end

return Command

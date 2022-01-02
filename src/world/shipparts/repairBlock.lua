-- Components
local Hull = require("world/shipparts/hull")
local Sensor = require("world/shipparts/sensor")
local Repair = require("world/shipparts/repair")

-- Graphics
local Draw = require("world/draw")
local imageFunctionInactive = Draw.createDrawBlockFunction("repairBlock")
local imageFunctionActive = Draw.createDrawBlockFunction("repairBlockActive")

-- Class Setup
local Part = require("world/shipparts/part")
local RepairBlock = class(Part)

function RepairBlock:__create()
	local sensor = Sensor(2)
	local repair = Repair(sensor:getBodyList())
	local imagefunction = function(...)
		if repair.active then
			imageFunctionActive(...)
		else
			imageFunctionInactive(...)
		end
	end
	self.modules["hull"] = Hull(imagefunction, 10)
	-- Engines can only connect to things on their top side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	local modules = self.modules

	modules["sensor"] = sensor
	modules["repair"] = repair
end

function RepairBlock:addFixtures(body)
	Part.addFixtures(self, body)
	local l = self.location
	self.modules.sensor:addFixtures(body, l[1], l[2])
	self.modules.repair:setTeam(body:getUserData():getTeam())
end

function RepairBlock:removeFixtures()
	Part.removeFixtures(self)
	self.modules.sensor:removeFixtures()
end

return RepairBlock

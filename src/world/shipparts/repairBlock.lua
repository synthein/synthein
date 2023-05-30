-- Components
local Hull = require("world/shipparts/modules/hull")
local Sensor = require("world/shipparts/modules/sensor")
local Repair = require("world/shipparts/modules/repair")

-- Class Setup
local Part = require("world/shipparts/part")
local RepairBlock = class(Part)

-- Graphics
local Draw = require("world/draw")
RepairBlock.image = Draw.loadImage("repairBlock")
RepairBlock.imageActive = Draw.loadImage("repairBlockActive")
local imageFunctionInactive = Draw.createDrawBlockFunction(RepairBlock.image)
local imageFunctionActive = Draw.createDrawBlockFunction(RepairBlock.imageActive)

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
	self.modules.repair:setTeam(body:getUserData().team)
end

function RepairBlock:removeFixtures()
	Part.removeFixtures(self)
	self.modules.sensor:removeFixtures()
end

function RepairBlock:update(moduleInputs, location)
	local newObject, disconnect
	
	self.modules.sensor:update(moduleInputs, location)
	self.modules.repair:update(moduleInputs, location)
	_, disconnect = self.modules.hull:update(moduleInputs, location)
	
	return newObject, disconnect
end

return RepairBlock

local Hull = require("world/shipparts/hull")
local Sensor = require("world/shipparts/sensor")
local Repair = require("world/shipparts/repair")

-- Utilities
local Draw = require("world/draw")

local lume = require("vendor/lume")

local Part = require("world/shipparts/part")
local RepairBlock = class(Part)

function RepairBlock:__create()
	self.modules["hull"] = Hull("repairBlock", 10)
	-- Engines can only connect to things on their top side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	local modules = self.modules

	local sensor = Sensor(2)
	local repair = Repair(sensor:getBodyList())
	modules["sensor"] = sensor
	modules["repair"] = repair

	local drawActive, drawInactive
	local userData = {}
	function userData:draw(fixture, scaleByHealth)
		local draw
		if repair.active then
			lume.once(function()
				self.image = "repairBlockActive"
				drawActive = Draw.createPartDrawImageFunction("repairBlockActive")
			end)()
			draw = drawActive
		else
			lume.once(function()
				self.image = "repairBlock"
				drawInactive = Draw.createPartDrawImageFunction("repairBlock")
			end)()
			draw = drawInactive
		end

		draw(self, fixture, scaleByHealth)
	end
	self.modules["hull"].userData.draw = userData.draw
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

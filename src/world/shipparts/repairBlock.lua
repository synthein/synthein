local Sensor = require("world/shipparts/sensor")
local Repair = require("world/shipparts/repair")

-- Utilities
local LocationTable = require("locationTable")
local WorldObjects = require("world/worldObjects")

local Part = require("world/shipparts/part")
local RepairBlock = class(Part)

function RepairBlock:__create()
	local imageInactive = "repairBlock"
	local imageActive = "repairBlockActive"
	self.image = imageInactive

	-- Engines can only connect to things on their top side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	local modules = self.modules

	local sensor = Sensor(2)
	local repair = Repair(sensor:getBodyList())
	modules["sensor"] = sensor
	modules["repair"] = repair

	local drawInactive
	local drawActive
	function self.userData:draw(fixture, scaleByHealth)
		if scaleByHealth then
			c = modules.health:getScaledHealth()
			love.graphics.setColor(1, c, c, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end

		if repair.active then
			drawActive = drawActive or WorldObjects.createDrawImageFunction(imageActive, 1, 1)
			draw = drawActive
		else
			drawInactive = drawInactive or WorldObjects.createDrawImageFunction(imageInactive, 1, 1)
			draw = drawInactive
		end

		draw(self, fixture)

		love.graphics.setColor(1, 1, 1, 1)
	end
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

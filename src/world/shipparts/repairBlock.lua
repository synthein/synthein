local Sensor = require("world/shipparts/sensor")

-- Utilities
local LocationTable = require("locationTable")

local Part = require("world/shipparts/part")
local RepairBlock = class(Part)

function RepairBlock:__create()
    local image = love.graphics.newImage("res/images/repairBlock.png")
	self.image = image
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	-- Engines can only connect to things on their top side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	local modules = self.modules

    local sensor = Sensor(2)
    modules["sensor"] = sensor

	function self.userData:draw(fixture, scaleByHealth)
		if scaleByHealth then
			c = modules.health:getScaledHealh()
			love.graphics.setColor(1, c, c, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
        --print(#sensor:getBodyList())
        if next(sensor.bodyList) then
            love.graphics.setColor(0,0,0, 1)
        end
		local x, y, angle = LocationTable(fixture, self.location):getXYA()
		love.graphics.draw(
			image,
			x, y, angle,
			1/self.width, -1/self.height, self.width/2, self.height/2)
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function RepairBlock:addFixtures(body)
	Part.addFixtures(self, body)
    local l = self.location
	self.modules.sensor:addFixtures(body, l[1], l[2])
end

function RepairBlock:removeFixtures()
	Part.removeFixtures(self)
	self.modules.sensor:removeFixtures()
end

return RepairBlock

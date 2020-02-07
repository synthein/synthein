-- Component
local Engine = require("world/shipparts/engine")

-- Utilities
local LocationTable = require("locationTable")

local EngineBlock = class(require("world/shipparts/part"))

function EngineBlock:__create()
	local imageInactive = love.graphics.newImage("res/images/engine.png")
	local imageActive = love.graphics.newImage("res/images/engineActive.png")
	self.image = imageInactive
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	local engine = Engine(2, 15)
	self.modules["engine"] = engine

	local isActive = engine:getIsActive()
	local modules = self.modules

	function self.userData:draw(fixture, scaleByHealth)
		if scaleByHealth then
			c = modules.health:getScaledHealh()
			love.graphics.setColor(1, c, c, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		local x, y, angle = LocationTable(fixture, self.location):getXYA()
		local image = imageInactive
		if isActive() then image = imageActive end
		love.graphics.draw(
			image,
			x, y, angle,
			1/self.width, -1/self.height, self.width/2, self.height/2)
			love.graphics.setColor(1, 1, 1, 1)
	end
end

return EngineBlock

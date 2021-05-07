-- Component
local Engine = require("world/shipparts/engine")

-- Utilities
local LocationTable = require("locationTable")
local WorldObjects = require("world/worldObjects")

local EngineBlock = class(require("world/shipparts/part"))

function EngineBlock:__create()
	local imageInactive = "engine"
	local imageActive = "engineActive"
	self.image = imageInactive
	self.width, self.height = 1, 1

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	local engine = Engine(2, 15)
	self.modules["engine"] = engine

	local isActive = engine:getIsActive()
	local modules = self.modules

	local drawInactive
	local drawActive
	function self.userData:draw(fixture, scaleByHealth)
		if scaleByHealth then
			c = modules.health:getScaledHealth()
			love.graphics.setColor(1, c, c, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end

		if isActive() then
			drawActive = drawActive or WorldObjects.createDrawImageFunction(imageActive, self.width, self.height)
			draw = drawActive
		else
			drawInactive = drawInactive or WorldObjects.createDrawImageFunction(imageInactive, self.width, self.height)
			draw = drawInactive
		end

		draw(self, fixture)

		love.graphics.setColor(1, 1, 1, 1)
	end
end

return EngineBlock

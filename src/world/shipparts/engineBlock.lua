-- Component
local Engine = require("world/shipparts/engine")

-- Utilities
local Draw = require("world/draw")
local LocationTable = require("locationTable")
local WorldObjects = require("world/worldObjects")
local Part = require("world/shipparts/part")

local lume = require("vendor/lume")

local EngineBlock = class(Part)

function EngineBlock:__create()
	local imageInactive = "engine"
	local imageActive = "engineActive"
	self.image = imageInactive

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	local engine = Engine(2, 15)
	self.modules["engine"] = engine

	local isActive = engine:getIsActive()
	local modules = self.modules

	local drawActive, drawInactive
	function self.userData:draw(fixture, scaleByHealth)
		local draw
		if isActive() then
			lume.once(function()
				self.image = imageActive
				drawActive = Draw.createPartDrawImageFunction()
			end)()
			draw = drawActive
		else
			lume.once(function()
				self.image = imageInactive
				drawInactive = Draw.createPartDrawImageFunction()
			end)()
			draw = drawInactive
		end

		draw(self, fixture, scaleByHealth)
	end
end

return EngineBlock

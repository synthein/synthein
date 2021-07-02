-- Component
local Hull = require("world/shipparts/hull")
local Engine = require("world/shipparts/engine")

-- Utilities
local Draw = require("world/draw")
local Part = require("world/shipparts/part")

local lume = require("vendor/lume")

local EngineBlock = class(Part)

function EngineBlock:__create()
	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	local hull = Hull("engine", 10)
	local engine = Engine(2, 15)



	self.modules["hull"] = hull
	self.modules["engine"] = engine

	local isActive = engine:getIsActive()
	local drawActive, drawInactive
	local userData = {}
	function userData:draw(fixture, scaleByHealth)
		local draw
		if isActive() then
			lume.once(function()
				self.image = imageActive
				drawActive = Draw.createPartDrawImageFunction("engineActive")
			end)()
			draw = drawActive
		else
			lume.once(function()
				self.image = imageInactive
				drawInactive = Draw.createPartDrawImageFunction("engine")
			end)()
			draw = drawInactive
		end

		draw(self, fixture, scaleByHealth)
	end
	self.modules["hull"].userData.draw = userData.draw
end

return EngineBlock

-- Components
local Hull = require("world/shipparts/hull")
local Engine = require("world/shipparts/engine")

-- Graphics
local Draw = require("world/draw")
local imageFunctionInactive = Draw.createDrawBlockFunction("engine")
local imageFunctionActive = Draw.createDrawBlockFunction("engineActive")

-- Class Setup
local Part = require("world/shipparts/part")
local EngineBlock = class(Part)

function EngineBlock:__create()
	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	local engine = Engine(2, 15)
	local imageFunction = function(...)
		if engine.isActive then
			imageFunctionActive(...)
		else
			imageFunctionInactive(...)
		end
	end

	local hull = Hull(imageFunction, 10)
	self.modules["hull"] = hull
	self.modules["engine"] = engine
end

return EngineBlock

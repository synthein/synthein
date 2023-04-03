-- Components
local Hull = require("world/shipparts/hull")
local Engine = require("world/shipparts/engine")

-- Class Setup
local Part = require("world/shipparts/part")
local EngineBlock = class(Part)

-- Graphics
local Draw = require("world/draw")
EngineBlock.image = Draw.loadImage("engine")
EngineBlock.imageActive = Draw.loadImage("engineActive")
local imageFunctionInactive = Draw.createDrawBlockFunction(EngineBlock.image)
local imageFunctionActive = Draw.createDrawBlockFunction(EngineBlock.imageActive)

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

function EngineBlock:update(moduleInputs, location)
	local newObject, disconnect
	
	self.modules.engine:update(moduleInputs, location)
	_, disconnect = self.modules.hull:update(moduleInputs, location)
	
	return newObject, disconnect
end

return EngineBlock

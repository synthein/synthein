
local Hull = require("world/shipparts/modules/hull")

local Block = class(require("world/shipparts/part"))

local Draw = require("world/draw")
Block.image = Draw.loadImage("block")
local imageFunction = Draw.createDrawBlockFunction(Block.image)

function Block:__create()
	self.modules["hull"] = Hull(imageFunction, 10)
end

function Block:update(moduleInputs, location)
	local newObject, disconnect = self.modules.hull:update(
		moduleInputs, location)
	
	return newObject, disconnect
end

return Block

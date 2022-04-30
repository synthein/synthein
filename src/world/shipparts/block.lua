
local Hull = require("world/shipparts/hull")

local Block = class(require("world/shipparts/part"))

local Draw = require("world/draw")
Block.image = Draw.loadImage("block")
local imageFunction = Draw.createDrawBlockFunction(Block.image)

function Block:__create()
	self.modules["hull"] = Hull(imageFunction, 10)
end

return Block

-- Components
local Hull = require("world/shipparts/hull")

-- Class Setup
local Part = require("world/shipparts/part")
local ArmorBlock = class(Part)

-- Graphics
local Draw = require("world/draw")
ArmorBlock.image = Draw.loadImage("armorBlock")
local imageFunction = Draw.createDrawBlockFunction(ArmorBlock.image)

function ArmorBlock:__create()
	self.modules["hull"] = Hull(imageFunction, 20)
end

return ArmorBlock

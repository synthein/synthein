-- Components
local Hull = require("world/shipparts/hull")

-- Graphics
local Draw = require("world/draw")
local imageFunction = Draw.createDrawBlockFunction("armorBlock")

-- Class Setup
local Part = require("world/shipparts/part")
local ArmorBlock = class(Part)

function ArmorBlock:__create()
	self.modules["hull"] = Hull(imageFunction, 20)
end

return ArmorBlock

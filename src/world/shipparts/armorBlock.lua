local Draw = require("world/draw")
local imageFunction = Draw.createDrawBlockDrawFunction("armorBlock")

-- Components
local Hull = require("world/shipparts/hull")

local ArmorBlock = class(require("world/shipparts/part"))

function ArmorBlock:__create()
	self.modules["hull"] = Hull(imageFunction, 20)
end

return ArmorBlock

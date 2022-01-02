-- Components
local Hull = require("world/shipparts/hull")

-- Graphics
local Draw = require("world/draw")
local imageFunction = Draw.createDrawBlockFunction("shield")

-- Class Setup
local Part = require("world/shipparts/part")
local ShieldBlock = class(Part)

function ShieldBlock:__create()
	self.modules["hull"] = Hull(imageFunction, 10)
	self.isShield = true

	return self
end

return ShieldBlock

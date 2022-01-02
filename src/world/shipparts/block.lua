local Draw = require("world/draw")
local imageFunction = Draw.createDrawBlockFunction("block")

local Hull = require("world/shipparts/hull")

local Block = class(require("world/shipparts/part"))

function Block:__create()
	self.modules["hull"] = Hull(imageFunction, 10)
end

return Block

-- Components
local Hull = require("world/shipparts/hull")

local ArmorBlock = class(require("world/shipparts/part"))

function ArmorBlock:__create()
	self.modules["hull"] = Hull("armorBlock", 20)
end

return ArmorBlock

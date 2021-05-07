-- Components
local Health = require("world/shipparts/health")

local ArmorBlock = class(require("world/shipparts/part"))

function ArmorBlock:__create()
	self.image = "armorBlock"
	self.width, self.height = 1, 1

	self.modules.health = Health(20)
end

return ArmorBlock

-- Components
local Health = require("world/shipparts/health")

local ArmorBlock = class(require("world/shipparts/part"))

function ArmorBlock:__create()
	self.image = love.graphics.newImage("res/images/armorBlock.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.modules.health = Health(20)
end

return ArmorBlock

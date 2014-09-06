local Block = require("block")

local Anchor = {}
Anchor.__index = Anchor
setmetatable(Anchor, Block)

function Anchor.create(world, x, y)
	local self = Block.create(world, x, y)
	setmetatable(self, Anchor)
	
	self.image = love.graphics.newImage("anchor.png")
	self.body:setType("static")

	return self
end

return Anchor

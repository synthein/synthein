local Block = class(require("world/shipparts/part"))

function Block:__create()
	self.image = love.graphics.newImage("res/images/block.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	return self
end

return Block

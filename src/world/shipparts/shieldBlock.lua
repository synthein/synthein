local ShieldBlock = class(require("world/shipparts/part"))

function ShieldBlock:__create()
	self.image = love.graphics.newImage("res/images/shield.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
-- Debug
print("shieldBlock create")
	return self
end

return ShieldBlock

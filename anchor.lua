Anchor = {}
Anchor.__index = Anchor

function Anchor.create()
	local self = setmetatable({}, Anchor)
	
	self.image = love.graphics.newImage("anchor.png")
	self.x = 50
	self.y = 50

	return self
end

function Anchor:update()
end

function Anchor:draw()
	love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, 10, 10)
end

return Anchor

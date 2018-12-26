-- Component
local Engine = require("world/shipparts/engine")

local EngineBlock = class(require("world/shipparts/part"))

function EngineBlock:__create()
	self.imageInactive = love.graphics.newImage("res/images/engine.png")
	self.imageActive = love.graphics.newImage("res/images/engineActive.png")
	self.image = self.imageInactive
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	self.engine = Engine(2, 15)

	return self
end

function EngineBlock:draw()
	local x, y, angle = self:getWorldLocation():getXYA()
	if x and y and angle then
		local image
		if self.engine.isActive then
			image = self.imageActive
		else
			image = self.imageInactive
		end
		love.graphics.draw(image, x, y, angle, 1/self.width, -1/self.height, self.width/2, self.height/2)
	end
end

return EngineBlock

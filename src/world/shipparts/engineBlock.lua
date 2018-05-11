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

function EngineBlock:update(_, partsInfo) --(dt, partsInfo)
	-- Update engine and set correct image.
	if self.engine:update(self, partsInfo.engines) then
		self.image = self.imageActive
	else
		self.image = self.imageInactive
	end
end

return EngineBlock

local Engine = require("shipparts/engine")
local Part = require("shipparts/part")
local EngineBlock = {}
EngineBlock.__index = EngineBlock
setmetatable(EngineBlock, Part)

function EngineBlock.create(world, x, y)
	local self = Part.create()
	setmetatable(self, EngineBlock)

	self.imageInactive = love.graphics.newImage("res/images/engine.png")
	self.imageActive = love.graphics.newImage("res/images/engineActive.png")
	self.image = self.imageInactive
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	self.engine = Engine.create(2, 15)

	return self
end

function EngineBlock:update(dt, partsInfo)
	if self.engine:update(self, partsInfo.engines) then
		self.image = self.imageActive
	else
		self.image = self.imageInactive
	end
end

return EngineBlock

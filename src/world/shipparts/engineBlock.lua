-- Component
local Engine = require("world/shipparts/engine")

-- Utilities
local LocationTable = require("locationTable")

local EngineBlock = class(require("world/shipparts/part"))

function EngineBlock:__create()
	local imageInactive = love.graphics.newImage("res/images/engine.png")
	local imageActive = love.graphics.newImage("res/images/engineActive.png")
	self.image = imageInactive
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	self.engine = Engine(2, 15)

	local isActive = self.engine:getIsActive()

	function self.userData:draw(fixture)
		local x, y, angle = LocationTable(fixture, self.location):getXYA()
		local image = imageInactive
		if isActive() then image = imageActive end
		love.graphics.draw(
			image,
			x, y, angle,
			1/self.width, -1/self.height, self.width/2, self.height/2)
	end
end

return EngineBlock

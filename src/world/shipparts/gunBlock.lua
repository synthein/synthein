-- Component
local Gun = require("world/shipparts/gun")

local GunBlock = class(require("world/shipparts/part"))

function GunBlock:__create()
	self.image = love.graphics.newImage("res/images/gun.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.gun = Gun()

	-- GunBlocks can only connect to things on their bottom side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	return self
end

function GunBlock:update(dt, partsInfo)
	local shoot = false
	if partsInfo.guns and partsInfo.guns.shoot then shoot = true end
	-- Update engine and return value in case there is a new shot.
	return self.gun:update(dt, shoot, self)
end

return GunBlock

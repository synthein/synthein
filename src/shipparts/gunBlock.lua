local Part = require("shipparts/part")
local Gun = require("shipparts/gun")

local GunBlock = {}
GunBlock.__index = GunBlock
setmetatable(GunBlock, Part)

function GunBlock.create(world, x, y)
	local self = Part.create()
	setmetatable(self, GunBlock)

	self.image = love.graphics.newImage("res/images/gun.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)

	self.gun = Gun.create()

	-- GunBlocks can only connect to things on their bottom side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	return self
end

function GunBlock:update(dt, partsInfo, location, locationSign, orientation)
	self:setLocation(location, partsInfo.locationInfo, orientation)

	local shoot = false
	if partsInfo.guns and partsInfo.guns.shoot then shoot = true end
	local newObject = self.gun:update(dt, shoot, self.location, self)

	return newObject
end

return GunBlock

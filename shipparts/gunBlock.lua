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
	local l = partsInfo.locationInfo[1]
	local directionX = partsInfo.locationInfo[2][1]
	local directionY = partsInfo.locationInfo[2][2]
	local x = (location[1] * directionX - location[2] * directionY) * 20 + l[1]
	local y = (location[1] * directionY + location[2] * directionX) * 20 + l[2]
	location = {x, y, l[3]}

	local shoot = false
	if partsInfo.guns and partsInfo.guns.shoot then shoot = true end
	local newobject = self.gun:update(dt, shoot, location, self)

	return newObject
end

return GunBlock

local Part = require("shipparts/part")

local Gun = {}
Gun.__index = Gun
setmetatable(Gun, Part)

function Gun.create(world, x, y)
	local self = Part.create()
	setmetatable(self, Gun)

	self.image = love.graphics.newImage("res/images/gun.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)

	self.gun = true
	self.recharge = false
	self.rechargeStart = 0
	-- Guns can only connect to things on their bottom side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	return self
end

function Gun:update(dt, partsInfo, location, locationSign, orientation)
	if self.recharge then
		self.rechargeStart = self.rechargeStart + dt
		if self.rechargeStart > 0.5 then
			self.recharge = false
		end
	end
	if  partsInfo.guns and partsInfo.guns.shoot and not self.recharge then
		local l = partsInfo.locationInfo[1]
		local directionX = partsInfo.locationInfo[2][1]
		local directionY = partsInfo.locationInfo[2][2]
		a = {directionX, directionY}
		local x = (location[1] * directionX - location[2] * directionY) * 20 + l[1]
		local y = (location[1] * directionY + location[2] * directionX) * 20 + l[2]
		self.recharge = true
		self.rechargeStart = 0
		local location = {x, y, l[3]}
		return {"shots", location, self}
	end
end

return Gun

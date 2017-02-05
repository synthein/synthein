local Part = require("shipparts/part")
local Gun = require("shipparts/gun")

local PlayerBlock = {}
PlayerBlock.__index = PlayerBlock
setmetatable(PlayerBlock, Part)

function PlayerBlock.create()
	local self = Part.create()
	setmetatable(self, PlayerBlock)

	self.image = love.graphics.newImage("res/images/player.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.thrust = 150
	self.torque = 350
	self.type = "control"
	self.gun = Gun.create()
	self.healTime = 10
	self.orders = {}

	self.isPlayer = true

	self.team = 1
	return self
end

function PlayerBlock:getTeam()
	return self.team
end

function PlayerBlock:setOrders(orders)
	self.orders = orders
end
function PlayerBlock:getOrders()
	return self.orders
end

function PlayerBlock:shot()
	self.recharge = true
	self.rechargeStart = 0
end

function PlayerBlock:update(dt, partsInfo, location, locationSign, orientation)
	self.healTime = self.healTime - dt
	if self.healTime <= 0 then
		self.healTime = self.healTime + 10
		if self.health < 10 then
			self.health = self.health + 1
		end
	end

	local l = partsInfo.locationInfo[1]
	local directionX = partsInfo.locationInfo[2][1]
	local directionY = partsInfo.locationInfo[2][2]
	local x = (location[1] * directionX - location[2] * directionY) * 20 + l[1]
	local y = (location[1] * directionY + location[2] * directionX) * 20 + l[2]
	location = {x, y, l[3]}

	local shoot = false
	if partsInfo.guns and partsInfo.guns.shoot then shoot = true end
	local newobject = self.gun:update(dt, shoot, location, self)
	
	local engines = partsInfo.engines
	local body = engines[8]
	local appliedForceX = -directionY * engines[5] + directionX * engines[6]
	local appliedForceY = directionX * engines[5] + directionY * engines[6]
	local Fx = appliedForceX * self.thrust
	local Fy = appliedForceY * self.thrust
	body:applyForce(Fx, Fy, location[1], location[2])
	body:applyTorque(engines[7] * self.torque)
	
	return newobject
end

return PlayerBlock

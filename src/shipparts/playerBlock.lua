local Part = require("shipparts/part")
local Gun = require("shipparts/gun")
local Settings = require("settings")

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
	self.location = location
	self.orientation = orientation


	local shoot = false
	if partsInfo.guns and partsInfo.guns.shoot then shoot = true end
	local newobject = self.gun:update(dt, shoot, self.location, self)

	local body = self.fixture:getBody()
	if self.location and body and partsInfo.engines then
		local angle = (self.orientation - 1) * math.pi/2 + body:getAngle()
		local x, y = unpack(self.location)
		x, y = body:getWorldPoints(x * Settings.PARTSIZE, y * Settings.PARTSIZE)

		local engines = partsInfo.engines
		fx, fy = body:getWorldVector(engines[6], engines[5])
		
		body:applyForce(fx * self.thrust, fy * self.thrust, x, y)
		body:applyTorque(engines[7] * self.torque)
	end

	self.healTime = self.healTime - dt
	if self.healTime <= 0 then
		self.healTime = self.healTime + 10
		if self.health < 10 then
			self.health = self.health + 1
		end
	end

	return newobject
end

return PlayerBlock

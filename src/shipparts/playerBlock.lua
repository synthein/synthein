local Part = require("shipparts/part")
local Engine = require("shipparts/engine")
local Gun = require("shipparts/gun")
local Settings = require("settings")

local PlayerBlock = {}
PlayerBlock.__index = PlayerBlock
setmetatable(PlayerBlock, Part)

function PlayerBlock.create(team, leader)
	local self = Part.create()
	setmetatable(self, PlayerBlock)

	self.image = love.graphics.newImage("res/images/player.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.type = "control"

	self.engine = Engine.create(1, 150, 350)
	self.gun = Gun.create()
	self.healTime = 10
	self.orders = {}

	self.isPlayer = true
	self.team = team
	self.leader = leader

	return self
end

function PlayerBlock:postCreate(references)
	if self.leader and type(self.leader) == "string" then
		self.leader = references[self.leader]
	end
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
	local newobject = self.gun:update(dt, shoot, self)

	self.engine:update(self, partsInfo.engines, locationSign)

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

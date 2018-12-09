local Engine = require("world/shipparts/engine")
local Gun = require("world/shipparts/gun")

local PlayerBlock = class(require("world/shipparts/part"))

function PlayerBlock:__create(team, leader)
	self.image = love.graphics.newImage("res/images/player.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.type = "control"

	self.engine = Engine(1, 15, 5)
	self.gun = Gun()
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

function PlayerBlock:update(dt, partsInfo)
	self.engine:update(self, partsInfo.engines)

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

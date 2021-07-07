-- Components
local Hull = require("world/shipparts/hull")
local Engine = require("world/shipparts/engine")
local Gun = require("world/shipparts/gun")
local Heal = require("world/shipparts/heal")

-- Graphics
local Draw = require("world/draw")
local imagefunction = Draw.createDrawBlockFunction("player")

-- Class Setup
local Part = require("world/shipparts/part")
local PlayerBlock = class(Part)

function PlayerBlock:__create(team, leader)
	self.modules["hull"] = Hull(imagefunction, 10)
	self.type = "control"

	self.modules["engine"] = Engine(1, 15, 5)
	self.modules["gun"] = Gun()
	self.modules["heal"] = Heal(self.modules["hull"])
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

return PlayerBlock

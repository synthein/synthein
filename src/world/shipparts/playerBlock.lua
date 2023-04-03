-- Components
local Hull = require("world/shipparts/hull")
local Engine = require("world/shipparts/engine")
local Gun = require("world/shipparts/gun")
local Heal = require("world/shipparts/heal")

-- Class Setup
local Part = require("world/shipparts/part")
local PlayerBlock = class(Part)

-- Graphics
local Draw = require("world/draw")
local imageFunctions = {}
for team = 1,2 do
	imageFunctions[team] = Draw.createDrawBlockFunction(Draw.loadImage("player" .. team))
end
PlayerBlock.image = Draw.loadImage("player1")

function PlayerBlock:__create(team, leader)
	self.modules["hull"] = Hull(imageFunctions[team], 10)
	self.type = "control"

	self.modules["engine"] = Engine(1, 15, 5)
	self.modules["gun"] = Gun()
	self.modules["heal"] = Heal(self.modules["hull"])
	self.orders = {}

	self.isPlayer = true
	self.team = team
	self.leader = leader

	self.formationCounter = 1

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

function PlayerBlock:getFormationPosition(key)
	local fc = self.formationCounter
	local p
	if self.formationFlag then
		p ={10 * fc, -5 * fc}
		self.formationFlag = false
		self.formationCounter = fc + 1
	else
		p = {-10 * fc, -5 * fc}
		self.formationFlag = true
	end
	return p
end

function PlayerBlock:setOrders(orders)
	self.orders = orders
end
function PlayerBlock:getOrders()
	return self.orders
end

function PlayerBlock:update(moduleInputs, location)
	local newObject, disconnect
	
	self.modules.engine:update(moduleInputs, location)
	newObject, _ = self.modules.gun:update(moduleInputs, location)
	self.modules.heal:update(moduleInputs, location)
	_, disconnect = self.modules.hull:update(moduleInputs, location)
	
	return newObject, disconnect
end

return PlayerBlock

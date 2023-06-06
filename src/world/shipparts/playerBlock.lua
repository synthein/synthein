-- Components
local Hull = require("world/shipparts/modules/hull")
local Engine = require("world/shipparts/modules/engine")
local Command = require("world/shipparts/modules/command")
local Gun = require("syntheinrust").shipparts.modules.gun
local Heal = require("syntheinrust").shipparts.modules.heal

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
	self.modules["command"] = Command()
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

function PlayerBlock:getCommand()
	return self.modules.command
end

function PlayerBlock:setOrders(orders)
	self.orders = orders
end

function PlayerBlock:getOrders()
	return self.orders
end

function PlayerBlock:update(moduleInputs, location)
	local newObject, disconnect
	
	self.modules.command:update(moduleInputs.dt)
	self.modules.engine:update(moduleInputs, location)
	newObject, _ = self.modules.gun:update(moduleInputs, location)
	self.modules.heal:update(moduleInputs, location)
	_, disconnect = self.modules.hull:update(moduleInputs, location)
	
	return newObject, disconnect
end

return PlayerBlock

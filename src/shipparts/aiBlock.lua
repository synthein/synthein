local Part = require("shipparts/part")
local Engine = require("shipparts/engine")
local AI = require("ai")
local Settings = require("settings")

local AIBlock = {}
AIBlock.__index = AIBlock
setmetatable(AIBlock, Part)

function AIBlock.create(team, leader)
	local self = Part.create()
	setmetatable(self, AIBlock)

	self.image = love.graphics.newImage("res/images/ai.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.type = "control"

	self.engine = Engine.create(1, 10, 10)
	self.ai = AI.create(team)
	self.leader = leader

	return self
end

function AIBlock:postCreate(references)
	if self.leader and type(self.leader) == "string" then
		self.leader = references[self.leader]
	end
end

function AIBlock:getTeam()
	return self.ai.team
end

function AIBlock:getOrders(location, worldInfo)
	return self.ai:getOrders(location, worldInfo, self.leader,
							 self.fixture:getBody())
end

function AIBlock:getMenu()
	return self.ai:getMenu()
end

function AIBlock:runMenu(i)
	return self.ai:runMenu(i)
end

function AIBlock:update(dt, partsInfo)
	self.engine:update(self, partsInfo.engines)
end

return AIBlock

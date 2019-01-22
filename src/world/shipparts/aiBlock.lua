local Engine = require("world/shipparts/engine")
local AI = require("world/shipparts/ai")

local AIBlock = class(require("world/shipparts/part"))

function AIBlock:__create(team, leader)
	self.image = love.graphics.newImage("res/images/ai.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.type = "control"

	self.modules["engine"] = Engine(1, 10, 10)
	self.modules["ai"] = AI(team)
	self.leader = leader
end

function AIBlock:postCreate(references)
	if self.leader and type(self.leader) == "string" then
		self.leader = references[self.leader]
	end
end

function AIBlock:getTeam()
	return self.modules.ai.team
end

function AIBlock:getOrders(body)
	return self.modules.ai:getOrders(self.worldInfo, self.leader, body)
end

function AIBlock:getMenu()
	return self.ai:getMenu()
end

function AIBlock:runMenu(i)
	return self.ai:runMenu(i)
end

return AIBlock

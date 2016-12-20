local Part = require("shipparts/part")
local AI = require("ai")

local AIBlock = {}
AIBlock.__index = AIBlock
setmetatable(AIBlock, Part)

function AIBlock.create(team)
	local self = Part.create()
	setmetatable(self, AIBlock)

	self.image = love.graphics.newImage("res/images/ai.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.thrust = 150
	self.torque = 350
	self.type = "control"

	self.ai = AI.create(team)

	return self
end

function AIBlock:getTeam()
	return self.ai.team
end

function AIBlock:getOrders(location, playerLocation, aiData)
	return self.ai:getOrders(location, playerLocation, aiData)
end

function AIBlock:getMenu()
	return self.ai:getMenu()
end

function AIBlock:runMenu(i)
	return self.ai:runMenu(i)
end

function AIBlock:update()
end

return AIBlock

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

function AIBlock:update(dt, partsInfo, location, locationSign, orientation)
	local engines = partsInfo.engines
	local body = engines[8]
	local l = partsInfo.locationInfo[1]
	local directionX = partsInfo.locationInfo[2][1]
	local directionY = partsInfo.locationInfo[2][2]
	local x = (location[1] * directionX - location[2] * directionY) * 20 + l[1]
	local y = (location[1] * directionY + location[2] * directionX) * 20 + l[2]
	local appliedForceX = -directionY * engines[5] + directionX * engines[6]
	local appliedForceY = directionX * engines[5] + directionY * engines[6]
	local Fx = appliedForceX * self.thrust
	local Fy = appliedForceY * self.thrust
	body:applyForce(Fx, Fy, x, y)
	body:applyTorque(engines[7] * self.torque)
end

return AIBlock

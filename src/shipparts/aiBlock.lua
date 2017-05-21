local Part = require("shipparts/part")
local AI = require("ai")
local Settings = require("settings")

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
	self.location = location
	self.orientation = orientation

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
end

return AIBlock

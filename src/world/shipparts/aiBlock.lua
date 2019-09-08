local Engine = require("world/shipparts/engine")
local AI = require("world/shipparts/ai")
local Sensor = require("world/shipparts/sensor")

local Part = require("world/shipparts/part")
local AIBlock = class(Part)

local images = {
	[-4] = love.graphics.newImage("res/images/ai-4.png"),
	[-3] = love.graphics.newImage("res/images/ai-3.png"),
	[-2] = love.graphics.newImage("res/images/ai-2.png"),
	[-1] = love.graphics.newImage("res/images/ai-1.png"),
	[ 1] = love.graphics.newImage("res/images/ai1.png"),
	[ 2] = love.graphics.newImage("res/images/ai2.png")
}

function AIBlock:__create(team, leader)
	self.image = images[team]
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.type = "control"

	self.modules["engine"] = Engine(1, 10, 10)
	self.modules["sensor"] = Sensor(200)
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

function AIBlock:addFixtures(body)
	Part.addFixtures(self, body)
	self.modules.sensor:addFixtures(body, 0, 0)
end

function AIBlock:removeFixtures()
	Part.removeFixtures(self)
	self.modules.sensor:removeFixtures()
end

function AIBlock:getOrders(body)
	return self.modules.ai:getOrders(
		self.worldInfo,
		self.leader,
		body,
		self.modules.sensor:getBodyList())
end

function AIBlock:getMenu()
	return self.ai:getMenu()
end

function AIBlock:runMenu(i)
	return self.ai:runMenu(i)
end

return AIBlock

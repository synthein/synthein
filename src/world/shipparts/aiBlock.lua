-- Components
local Hull = require("world/shipparts/hull")
local Engine = require("world/shipparts/engine")
local AI = require("world/shipparts/ai")
local Sensor = require("world/shipparts/sensor")

-- Graphics
local Draw = require("world/draw")
local aiTeams = {-4, -3, -2, -1, 1, 2}
local imageFunctions = {}
for i, team in ipairs(aiTeams) do
	imageFunctions[team] = Draw.createDrawBlockFunction("ai" .. team)
end

-- Class Setup
local Part = require("world/shipparts/part")
local AIBlock = class(Part)

function AIBlock:__create(team, leader)
	self.modules["hull"] = Hull(imageFunctions[team], 10)
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

-- Components
local Hull = require("world/shipparts/hull")
local Engine = require("world/shipparts/engine")
local Drone = require("world/shipparts/drone")
local Sensor = require("world/shipparts/sensor")

-- Graphics
local Draw = require("world/draw")
local droneTeams = {-4, -3, -2, -1, 1, 2}
local imageFunctions = {}
for i, team in ipairs(droneTeams) do
	imageFunctions[team] = Draw.createDrawBlockFunction(Draw.loadImage("drone" .. team))
end

-- Class Setup
local Part = require("world/shipparts/part")
local DroneBlock = class(Part)

DroneBlock.image = Draw.loadImage("drone" .. 1)

function DroneBlock:__create(team, leader)
	self.modules["hull"] = Hull(imageFunctions[team], 10)
	self.type = "control"

	self.modules["engine"] = Engine(1, 10, 10)
	self.modules["sensor"] = Sensor(200)
	self.modules["drone"] = Drone(team)
	self.leader = leader
end

function DroneBlock:postCreate(references)
	if self.leader and type(self.leader) == "string" then
		self.leader = references[self.leader]
	end
end

function DroneBlock:getTeam()
	return self.modules.drone.team
end

function DroneBlock:addFixtures(body)
	Part.addFixtures(self, body)
	self.modules.sensor:addFixtures(body, 0, 0)
end

function DroneBlock:removeFixtures()
	Part.removeFixtures(self)
	self.modules.sensor:removeFixtures()
end

function DroneBlock:getOrders(body)
	return self.modules.drone:getOrders(
		self.worldInfo,
		self.leader,
		body,
		self.modules.sensor:getBodyList())
end

function DroneBlock:getMenu()
	return self.modules.drone:getMenu()
end

function DroneBlock:runMenu(i, body)
	return self.modules.drone:runMenu(i, body)
end

return DroneBlock

local Camera = require("camera")
local PhysicsReferences = require("world/physicsReferences")
local Settings = require("settings")
local Spawn = require("world/spawn")

local lume = require("vendor/lume")

local Debug = {}

function Debug.create(world, players)
	local self = setmetatable({}, {__index = Debug})
	self.world = world
	self.players = players
	self.on = false
	self.spawn = false

	self.drawSensors = Camera.wrap(self.drawSensors, true)
	return self
end

function Debug:getSpawn()
	local value = Debug.spawn
	self.spawn = false
	return value
end

function Debug:draw()
	love.graphics.print(
		string.format("%3d", love.timer.getFPS()),
		love.graphics.getWidth() - 20, 0)
	for _, player in ipairs(self.players) do
		if player and player.camera then
			-- Gather debug data
			local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
			local mouseWorldX, mouseWorldY = player.camera:getWorldCoords(mouseX, mouseY)
			local shipParts
			local shipX, shipY

			if player.ship then
				shipX, shipY = player.ship.body:getX(), player.ship.body:getY()
				shipParts = #player.ship.body:getFixtures()
			else
				shipX, shipY = 0, 0
				shipParts = 0
			end

			self.drawSensors({world = self.world, camera = player.camera}, player)

			-- Print the debug information.
			player.camera:print(
				string.format("%.0f %.0f\n",
				              math.floor(mouseWorldX + 0.5),
				              math.floor(mouseWorldY + 0.5)),
				mouseX + 10, mouseY + 10
			)
			player.camera:print(
				string.format(
					"Ship position: (%.3f, %.3f)\n" ..
					"Number of ship parts: %d\n",
					shipX, shipY,
					shipParts
				)
			)
		end
	end
end

-- Show invisible sensors.
function Debug:drawSensors(player)
	love.graphics.push("all")
	love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
	love.graphics.setLineWidth(2/Settings.PARTSIZE)

	local sensors = {}
	local a, b, c, d = player.camera:getWorldBorder()
	self.world.physics:queryBoundingBox(a, b, c, d, function(fixture)
		local category = fixture:getFilterData()
		if category == PhysicsReferences.getCategory("sensor")
			 or category == PhysicsReferences.getCategory("shield") then
			table.insert(sensors, fixture)
		end
		return true
	end)

	for _, sensor in ipairs(sensors) do
		local shape = sensor:getShape()
		local type = shape:getType()

		if type == "circle" then
			local x, y = shape:getPoint()
			x, y = sensor:getBody():getWorldPoint(x, y)
			love.graphics.circle("line", x, y, shape:getRadius())
		elseif type == "polygon" then
			local local_points = {shape:getPoints()}
			local world_points = {}
			for i = 1, #local_points, 2 do
				local x, y = sensor:getBody():getWorldPoint(local_points[i], local_points[i+1])
				table.insert(world_points, x)
				table.insert(world_points, y)
			end
			love.graphics.polygon("line", world_points)
		else
			error("Unhandled shape type \"" .. type .. "\"")
		end
	end

	love.graphics.pop()
end

function Debug:update(dt)
end

function Debug:keyboard(key)
	--local world = Debug.world
	--local physics = world.physics
--	for i, player in ipairs(Debug.players) do

		if key == "n" then
			self.spawn = true

		elseif love.keyboard.isDown("lctrl", "rctrl") then
			-- Export the player's ship.
			if key == "s" then
				local string = Spawn.shipPack(self.player.ship, true)
				love.filesystem.write("playerShip.txt", string)
			end
		end
--	end
end

function Debug:mousepressed(mouseX, mouseY, button)
end

function Debug:mousereleased(x, y, button)
end

return Debug

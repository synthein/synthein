local Log = require("log")
local StructureParser = require("world/structureParser")
local Settings = require("settings")

local Debug = {}

local log = Log()

function Debug.create(world, players, drawTimeLogger)
	local self = setmetatable({}, {__index = Debug})
	self.world = world
	self.players = players
	self.on = false
	self.spawn = false
	self.drawTimeLogger = drawTimeLogger
	return self
end

function Debug:toggle()
	self.on = not self.on
	Settings.debug = self.on
end

function Debug:getSpawn()
	local value = self.spawn
	self.spawn = false
	return value
end

function Debug:update(dt)
	self.drawTimeLogger:update()
end

function Debug:draw()
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

	local chartWidth = #self.drawTimeLogger.times
	for i, t in ipairs(self.drawTimeLogger.times) do
		local y = math.floor(love.graphics.getHeight() - t*1000)
		love.graphics.points(i, y)
	end

	love.graphics.print(
		string.format("%07.4f", love.timer.getFPS()),
		chartWidth, love.graphics.getHeight() - 28)
	love.graphics.print(
		string.format("%07.4f", self.drawTimeLogger:average()),
		chartWidth, love.graphics.getHeight() - 14)
end

function Debug:keyboard(control)
	--local world = Debug.world
	--local physics = world.physics
--	for i, player in ipairs(Debug.players) do

		if control.ship == "debugSpawn" then
			self.spawn = true

		elseif control.ship == "debugSave" then
			-- Export the player's ship.
			for i, player in ipairs(self.players) do
				local filename = "playerShip"..i..".txt"
				local shipData = StructureParser.shipPack(player.ship, true)
				local ok, err = love.filesystem.write(filename, shipData)
				if ok then
					log:debug("Wrote %s/%s", love.filesystem.getSaveDirectory(), filename)
				else
					log:error(err)
				end
			end
		end
--	end
end

function Debug:mousepressed(mouseX, mouseY, button)
end

function Debug:mousereleased(x, y, button)
end

return Debug

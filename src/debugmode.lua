local Debug = {}

function Debug.create(world, players)
	local self = setmetatable({}, {__index = Debug})
	self.world = world
	self.players = players
	self.on = false
	self.spawn = false
	return self
end

function Debug:getSpawn()
	local value = self.spawn
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

function Debug:update(dt)
end

function Debug:keyboard(key)
	--local world = Debug.world
	--local physics = world.physics
--	for i, player in ipairs(Debug.players) do

		if key == "n" then
			self.spawn = true

		elseif love.keyboard.isDown("lctrl", "rctrl") then
			--TODO this functionality was destroyed at some point needs repair.
			-- Export the player's ship.
			--[[
			if key == "s" then
				local string = Spawn.shipPack(self.player.ship, true)
				love.filesystem.write("playerShip.txt", string)
			end
			--]]
		end
--	end
end

function Debug:mousepressed(mouseX, mouseY, button)
end

function Debug:mousereleased(x, y, button)
end

return Debug

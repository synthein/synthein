local Spawn = require("world/spawn")

local Debug = {}

-- This should be called when the game is initialized so that the debug tools
-- have access to the game world (It needs to look through the objects in the,
-- manipulate them, add new ones, etc.).
function Debug.setWorld(world)
	Debug.world = world
end

-- Similarly, give the debug tools access to the player so it can print debug
-- into about it.
function Debug.setPlayers(players)
	Debug.players = players
end

Debug.spawn = false
function Debug.getSpawn()
	local value = Debug.spawn
	Debug.spawn = false
	return value
end


-- Print debug info.
function Debug.draw()
	if not Debug.world then
		return
	end
	love.graphics.print(
		string.format("%3d", love.timer.getFPS()),
		love.graphics.getWidth() - 20, 0)
	for _, player in ipairs(Debug.players) do
		if player and player.camera then
			-- Gather debug data
			local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
			local mouseWorldX, mouseWorldY = player.camera:getWorldCoords(mouseX, mouseY)
			local buildStatus = player.build and "yes" or "no"
			local shipParts
			local shipX, shipY

			if player.ship then
				shipX, shipY = player.ship.body:getX(), player.ship.body:getY()
				shipParts = #player.ship.body:getFixtureList()
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
				string.format("Ship position: (%.3f, %.3f)\n" ..
				              "Number of ship parts: %d\n" ..
							  "Build mode: %s\n",
							  shipX, shipY,
				              shipParts,
							  buildStatus
				)
			)
		end
	end
end

function Debug.update() --(dt)
	if Debug.mouseJoint then
		local mouseWorldX, mouseWorldY =
			Debug.players[1].camera:getWorldCoords(love.mouse.getX(),
												   love.mouse.getY())
		Debug.mouseJoint:setTarget(mouseWorldX, mouseWorldY)
	end
end

function Debug.keyboard(key)
	--local world = Debug.world
	--local physics = world.physics
--	for i, player in ipairs(Debug.players) do

		if key == "n" then
			Debug.spawn = true

		elseif love.keyboard.isDown("lctrl", "rctrl") then
			-- Export the player's ship.
			if key == "s" then
				local string = Spawn.shipPack(Debug.player.ship, true)
				love.filesystem.write("playerShip.txt", string)
			end
		end
--	end
end

function Debug.mousepressed(_, _, button) --(mouseX, mouseY, button)
	local mouseWorldX, mouseWorldY =
		Debug.players[1].camera:getWorldCoords(love.mouse.getX(),
		                                       love.mouse.getY())
	if button == 3 then
		local structure = Debug.world:getStructure(mouseWorldX, mouseWorldY)
		if structure then
			Debug.mouseJoint = love.physics.newMouseJoint(structure.body,
														  mouseWorldX,
														  mouseWorldY)
			Debug.mouseJoint:setTarget(mouseWorldX, mouseWorldY)
		end
	end
end

function Debug.mousereleased(_, _, button) --(x, y, button)
	if button == 3 then
		if Debug.mouseJoint then
			Debug.mouseJoint:destroy()
			Debug.mouseJoint = nil
		end
	end
end

return Debug

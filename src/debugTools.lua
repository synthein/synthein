local Structure = require("structure")
local Spawn = require("spawn")

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
	for i, player in ipairs(Debug.players) do
		mouseWorldX, mouseWorldY =
			player.camera:getWorldCoords(love.mouse.getX(), love.mouse.getY())
		if player and player.camera then
			local debugString
			if player.ship then
				debugString = string.format(
					"%.3f    %.3f\n"..
					"%.3f    %.3f\n"..
					"Number of ship parts: %d\n"..
					"Build mode: %s\n",
					player.ship.body:getX(), player.ship.body:getY(),
					mouseWorldX, mouseWorldY,
					#player.ship.body:getFixtureList(),
					(player.build and "yes" or "no")
				)
			else
				debugString = string.format(
					"%.3f    %.3f\n"..
					"%.3f    %.3f\n"..
					"Number of chunks: %d\n"..
					"Number of ship parts: %d\n"..
					"Build mode: %s\n",
					0, 0,
					mouseWorldX, mouseWorldY,
					0, 0,
					(player.build and "yes" or "no")
				)
			end
			player.camera:print(debugString)
		end
	end
end

function Debug.update(dt)
	if Debug.mouseJoint then
		Debug.mouseJoint:setTarget(mouseWorldX, mouseWorldY)
	end
end

function Debug.keyboard(key)
	local world = Debug.world
	local physics = world.physics
	for i, player in ipairs(Debug.players) do

		if key == "n" then
			Debug.spawn = true

		elseif love.keyboard.isDown("lctrl", "rctrl") then
			-- Export the player's ship.
			if key == "s" then
				local string = Spawn.shipPack(Debug.player.ship, true)
				love.filesystem.write("playerShip.txt", string)
			end
		end
	end
end

function Debug.mousepressed(mouseX, mouseY, button)
		mouseWorldX, mouseWorldY =
			Debug.players[1].camera:getWorldCoords(love.mouse.getX(),
												   love.mouse.getY())
	if button == 3 then
		structure = Debug.world:getStructure(mouseWorldX, mouseWorldY)
		if structure then
			Debug.mouseJoint = love.physics.newMouseJoint(structure.body,
														  mouseWorldX,
														  mouseWorldY)
			Debug.mouseJoint:setTarget(mouseWorldX, mouseWorldY)
		end
	end
end

function Debug.mousereleased(x, y, button)
	if button == 3 then
		if Debug.mouseJoint then
			Debug.mouseJoint:destroy()
			Debug.mouseJoint = nil
		end
	end
end

return Debug

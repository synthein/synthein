local AI = require("ai")
local Structure = require("structure")
local Spawn = require("spawn")
local Screen = require("screen")

-- Ship parts
local AIBlock = require("aiBlock")
local Block = require("block")
local Engine = require("engine")
local Gun = require("gun")

local Debug = {}

-- This should be called when the game is initialized so that the debug tools
-- have access to the game world (It needs to look through the objects in the,
-- manipulate them, add new ones, etc.).
function Debug.setWorld(world)
	Debug.world = world
end

-- Similarly, give the debug tools access to the player so it can print debug
-- into about it.
function Debug.setPlayer(player)
	Debug.player1 = player
end

-- Print debug info.
function Debug.draw()
	mouseWorldX, mouseWorldY =
		Screen.getCursorCoords(love.mouse.getX(), love.mouse.getY())
	local debugString = string.format(
		"%.3f    %.3f\n"..
		"%.3f    %.3f\n"..
		"Number of world structures: %d\n"..
		"Number of ship parts: %d\n"..
		"Build mode: %s\n",
		Debug.player1.ship.body:getX(), Debug.player1.ship.body:getY(),
		mouseWorldX, mouseWorldY,
		#Debug.world.worldStructures,
		#Debug.world.playerShip.parts,
		(Debug.player1.build and "yes" or "no")
	)
	love.graphics.print(debugString, 5, 5)
end

function Debug.update(mouseWorldX, mouseWorldY)
	if Debug.mouseJoint then
		Debug.mouseJoint:setTarget(mouseWorldX, mouseWorldY)
	end
end

function Debug.keyboard(key, cameraX, cameraY)
	-- Spawn a ship part.
	if key == "u" then
		-- Spawn a block
		table.insert(Debug.world.worldStructures,
			Structure.create(Block.create(), Debug.world.physics,
			cameraX + 50, cameraY - 100))
	elseif key == "i" then
		-- Spawn an engine
		table.insert(Debug.world.worldStructures,
			Structure.create(Engine.create(), Debug.world.physics,
			cameraX + 112, cameraY))
	elseif key == "o" then
		-- Spawn a gun
		table.insert(Debug.world.worldStructures,
			Structure.create(Gun.create(), Debug.world.physics,
			cameraX + 50, cameraY + 100))

	--Spawn an AI
	elseif key == "1" then
		-- Team 1
		table.insert(Debug.world.aiShips,
			Structure.create(AIBlock.create(), Debug.world.physics,
			cameraX - 200, cameraY + 200))
		table.insert(Debug.world.ais,
			AI.create(Debug.world.aiShips[#Debug.world.aiShips], 1))
	elseif key == "2" then
		-- Team 2
		table.insert(Debug.world.aiShips,
			Structure.create(AIBlock.create(), Debug.world.physics,
			cameraX + 200, cameraY + 200))
		table.insert(Debug.world.ais,
			AI.create(Debug.world.aiShips[#Debug.world.aiShips], 2))
	elseif key == "3" then
		-- Team 3, etc.

	elseif love.keyboard.isDown("lctrl", "rctrl") then
		-- Export the player's ship.
		if key == "s" then
			local string = Spawn.shipPack(Debug.player1.ship, true)
			love.filesystem.write("playerShip.txt", string)
		end
	end
end

function Debug.mousepressed(mouseX, mouseY, button, mouseWorldX, mouseWorldY)
	if button == 3 then
		structure = Debug.world:getWorldStructure(mouseWorldX, mouseWorldY)
		if structure then
			Debug.mouseJoint = love.physics.newMouseJoint(structure.body, mouseWorldX, mouseWorldY)
			Debug.mouseJoint:setTarget(mouseWorldX, mouseWorldY)
		end
	end
end

function Debug.mousereleased(x, y, button, mouseWorldX, mouseWorldY)
	if button == 3 then
		if Debug.mouseJoint then
			Debug.mouseJoint:destroy()
			Debug.mouseJoint = nil
		end
	end
end

return Debug

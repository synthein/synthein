local Block = require("block")
local Engine = require("engine")
local Gun = require("gun")
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
function Debug.setPlayer(player)
	Debug.player1 = player
end

-- Print debug info.
function Debug.draw()
	local debugString = string.format(
		"%.3f    %.3f\n"..
		"Number of world structures: %d\n"..
		"Number of ship parts: %d\n"..
		"Build mode: %s\n",
		Debug.player1.ship.body:getX(), Debug.player1.ship.body:getY(),
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

function Debug.keyboard(key, globalOffsetX, globalOffsetY)
	-- Spawn a block
	if key == "u" then
		table.insert(Debug.world.worldStructures,
		Structure.create(Block.create(), Debug.world.physics,
		globalOffsetX + 50, globalOffsetY - 100))
	end
	-- Spawn an engine
	if key == "i" then
		table.insert(Debug.world.worldStructures,
		Structure.create(Engine.create(), Debug.world.physics,
		globalOffsetX + 112, globalOffsetY))
	end
	-- Spawn a gun
	if key == "o" then
		table.insert(Debug.world.worldStructures,
		Structure.create(Gun.create(), Debug.world.physics,
		globalOffsetX + 50, globalOffsetY + 100))
	end
	if key == "m" then
		local string = Spawn.shipPack(Debug.player1.ship, true)
		love.filesystem.write("playerShip.txt", string)
	end
end

function Debug.mousepressed(mouseX, mouseY, button, mouseWorldX, mouseWorldY)
	if button == 3 then
		structure = Debug.world:getWorldStructure(mouseWorldX, mouseWorldY)
		if structure then
			Debug.mouseJoint = love.physics.newMouseJoint(structure.body, mouseWorldX, mouseWorldY)
			Debug.mouseJoint:setTarget(mouseWorldX, mouseWorldY)
			print(Debug.mouseJoint)
		end
	end
end

function Debug.mousereleased(x, y, button, mouseWorldX, mouseWorldY)
	if button == 3 then
		if Debug.mouseJoint then
			Debug.mouseJoint:destroy()
			Debug.mouseJoint = nil
			print(Debug.mouseJoint)
		end
	end
end

return Debug

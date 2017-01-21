local AI = require("ai")
local Structure = require("structure")
local Spawn = require("spawn")
local Screen = require("screen")

-- Ship parts
local AIBlock = require("shipparts/aiBlock")
local Block = require("shipparts/block")
local Engine = require("shipparts/engine")
local Gun = require("shipparts/gun")

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
					#player.ship.parts,
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
					0,
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
	local cameraX, cameraY = Debug.players[1].camera:getPosition()
	local world = Debug.world
	-- Spawn a ship part.
	if key == "u" then
		-- Spawn a block
		world:createStructure(Block.create(), {cameraX + 50, cameraY + 100})
	elseif key == "i" then
		-- Spawn an engine
		world:createStructure(Engine.create(),{cameraX + 112, cameraY})
	elseif key == "o" then
		-- Spawn a gun
		world:createStructure(Gun.create(), {cameraX + 50, cameraY - 100})

	--Spawn an AI
	elseif key == "1" then
		-- Team 1
		world:createStructure(AIBlock.create(1), {cameraX - 200, cameraY + 200})
	elseif key == "2" then
		-- Team 2
		world:createStructure(AIBlock.create(2), {cameraX + 200, cameraY + 200})
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

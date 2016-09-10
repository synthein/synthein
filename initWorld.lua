local Anchor = require("shipparts/anchor")
local Block = require("shipparts/block")
local PlayerBlock = require("shipparts/playerBlock")
local AIBlock = require("shipparts/aiBlock")
local Structure = require("structure")
local Spawn = require("spawn")

local InitWorld = {}

function InitWorld.init(physics)

	local worldStructures = {}
	for i=1,10 do
		worldStructures[i] = Structure.create(Block.create(), physics, i*35, -i*35)
	end
	local aiShips = {}
	local string, length = Spawn.loadShipFromFile(2)
	local shipTable = Spawn.shipUnpack(string, length)
	aiShips[1] = Spawn.spawnShip(shipTable, physics, -200, 50)
	aiShips[2] = Structure.create(AIBlock.create(), physics, -35, 200)

	-- Create the anchor.
	local anchor = Structure.create(Anchor.create(), physics, -10, -10)
	anchor:addPart(Anchor.create(), 1, 0, 1)
	anchor:addPart(Anchor.create(), 0, 1, 1)
	anchor:addPart(Anchor.create(), 1, 1, 1)

	-- Create the player.
	local string, length = Spawn.loadShipFromFile(1)
	local shipTable = Spawn.shipUnpack(string, length)
	local playerShip = Spawn.spawnShip(shipTable, physics, 0, 100)--Structure.create(PlayerBlock.create(), physics, 0, 100)

	return worldStructures, anchor, playerShip, aiShips, physics
end

return InitWorld

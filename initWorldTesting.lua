local Anchor = require("anchor")
local Block = require("block")
local PlayerBlock = require("playerBlock")
local Engine = require("engine")
local Structure = require("structure")

local InitWorldTesting = {}

function InitWorldTesting.init(physics)

	local worldStructures = {}

	-- Create the anchor.
	local anchor = Structure.create(Anchor.create(), physics, -10, -10)
	anchor:addPart(Anchor.create(), 1, 0, 1)
	anchor:addPart(Anchor.create(), 0, 1, 1)
	anchor:addPart(Anchor.create(), 1, 1, 1)

	-- Create the player.
	local playerShip = Structure.create(PlayerBlock.create(), physics, 0, -100)

	playerShip:addPart(Block.create(world, 100, 100), 1, 0, 1)

	playerShip:addPart(Block.create(world, 100, 100), 2, 2, 1)
	playerShip:addPart(Block.create(world, 100, 100), 2, 1, 1)
	playerShip:addPart(Block.create(world, 100, 100), 2, 0, 1)
	playerShip:addPart(Block.create(world, 100, 100), 2, -1, 1)
	playerShip:addPart(Block.create(world, 100, 100), 2, -2, 1)

	playerShip:addPart(Block.create(world, 100, 100), 3, 2, 1)
	playerShip:addPart(Block.create(world, 100, 100), 3, -2, 1)


	playerShip:addPart(Block.create(world, 100, 100), -1, 0, 1)

	playerShip:addPart(Block.create(world, 100, 100), -2, 2, 1)
	playerShip:addPart(Block.create(world, 100, 100), -2, 1, 1)
	playerShip:addPart(Block.create(world, 100, 100), -2, 0, 1)
	playerShip:addPart(Block.create(world, 100, 100), -2, -1, 1)
	playerShip:addPart(Block.create(world, 100, 100), -2, -2, 1)

	playerShip:addPart(Block.create(world, 100, 100), -3, 2, 1)
	playerShip:addPart(Block.create(world, 100, 100), -3, -2, 1)




	playerShip:addPart(Engine.create(world, 100, 100), 0, 1, 1)
	playerShip:addPart(Engine.create(world, 100, 100), 0, -1, 3)
	playerShip:addPart(Engine.create(world, 100, 100), 3, 0, 4)
	playerShip:addPart(Engine.create(world, 100, 100), -3, 0, 2)

	playerShip:addPart(Engine.create(world, 100, 100), 1, 2, 2)
	playerShip:addPart(Engine.create(world, 100, 100), 3, 3, 1)
	playerShip:addPart(Engine.create(world, 100, 100), 4, 2, 4)
	playerShip:addPart(Engine.create(world, 100, 100), 3, 1, 3)

	playerShip:addPart(Engine.create(world, 100, 100), -1, 2, 4)
	playerShip:addPart(Engine.create(world, 100, 100), -3, 3, 1)
	playerShip:addPart(Engine.create(world, 100, 100), -4, 2, 2)
	playerShip:addPart(Engine.create(world, 100, 100), -3, 1, 3)

	playerShip:addPart(Engine.create(world, 100, 100), -1, -2, 4)
	playerShip:addPart(Engine.create(world, 100, 100), -3, -3, 3)
	playerShip:addPart(Engine.create(world, 100, 100), -4, -2, 2)
	playerShip:addPart(Engine.create(world, 100, 100), -3, -1, 1)
	
	playerShip:addPart(Engine.create(world, 100, 100), 1, -2, 2)
	playerShip:addPart(Engine.create(world, 100, 100), 3, -3, 3)
	playerShip:addPart(Engine.create(world, 100, 100), 4, -2, 4)
	playerShip:addPart(Engine.create(world, 100, 100), 3, -1, 1)

	aiShips = {}
	return worldStructures, anchor, playerShip, aiShips, physics
end

return InitWorldTesting

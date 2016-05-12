local Anchor = require("anchor")
local Block = require("block")
local ControlBlock = require("controlBlock")
local AIBlock = require("aiBlock")
local Structure = require("structure")

local InitWorld = {}

function InitWorld.init(physics)

	local worldStructures = {}
	for i=1,10 do
		worldStructures[i] = Structure.create(Block.create(), physics, i*35, i*35)
	end
	local aiShips = {}
	aiShips[1] = Structure.create(AIBlock.create(), physics, -35, -35)
	-- Create the anchor.
	local anchor = Structure.create(Anchor.create(), physics, -10, -10)
	anchor:addPart(Anchor.create(), 1, 0, 1)
	anchor:addPart(Anchor.create(), 0, 1, 1)
	anchor:addPart(Anchor.create(), 1, 1, 1)

	-- Create the player.
	local playerShip = Structure.create(ControlBlock.create(), physics, 0, -100)

	return worldStructures, anchor, playerShip, aiShips, physics
end

return InitWorld

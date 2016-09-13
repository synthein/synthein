local Anchor = require("anchor")
local Block = require("block")
local PlayerBlock = require("playerBlock")
local AIBlock = require("aiBlock")
local Structure = require("structure")
local Spawn = require("spawn")
local SceneParser = require("sceneParser")

local InitWorld = {}

function InitWorld.init(physics)

	local worldStructures = {}
	for i=1,10 do
		worldStructures[i] = Structure.create(Block.create(), physics, i*35, -i*35)
	end
	local aiShips = SceneParser.loadScene("scene1", 0, 0, physics)
	--aiShips[1] = Spawn.spawnShip("BasicShip2", physics, -200, 50)
	aiShips[2] = Structure.create(AIBlock.create(), physics, -35, 200)
	
	-- Create the anchor.
	local anchor = Structure.create(Anchor.create(), physics, -10, -10)
	anchor:addPart(Anchor.create(), 1, 0, 1)
	anchor:addPart(Anchor.create(), 0, 1, 1)
	anchor:addPart(Anchor.create(), 1, 1, 1)

	-- Create the player.
	local playerShip = Spawn.spawnShip("BasicShip1", physics, 0, 100)--Structure.create(PlayerBlock.create(), physics, 0, 100)

	return worldStructures, anchor, playerShip, aiShips, physics
end

return InitWorld

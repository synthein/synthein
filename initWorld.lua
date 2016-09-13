local Anchor = require("shipparts/anchor")
local Block = require("shipparts/block")
local PlayerBlock = require("shipparts/playerBlock")
local AIBlock = require("shipparts/aiBlock")
local Structure = require("structure")
local Spawn = require("spawn")
local SceneParser = require("sceneParser")

local InitWorld = {}

function InitWorld.init()

	local worldStructures = {}
	for i=1,10 do
		worldStructures[i] = Structure.create(Block.create(), i*35, -i*35)
	end
	local aiShips = SceneParser.loadScene("scene1", 0, 0)
	--aiShips[1] = Spawn.spawnShip("BasicShip2" -200, 50)
	aiShips[2] = Structure.create(AIBlock.create(), -35, 200)

	-- Create the anchor.
	local anchor = Structure.create(Anchor.create(), -10, -10)
	anchor:addPart(Anchor.create(), 1, 0, 1)
	anchor:addPart(Anchor.create(), 0, 1, 1)
	anchor:addPart(Anchor.create(), 1, 1, 1)

	-- Create the player.
	local playerShip = Spawn.spawnShip("BasicShip1", 0, 100)--Structure.create(PlayerBlock.create(), 0, 100)

	return worldStructures, anchor, playerShip, aiShips
end

return InitWorld

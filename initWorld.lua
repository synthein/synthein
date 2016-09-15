local Anchor = require("shipparts/anchor")
local Block = require("shipparts/block")
local PlayerBlock = require("shipparts/playerBlock")
local AIBlock = require("shipparts/aiBlock")
local Structure = require("structure")
local Spawn = require("spawn")
local SceneParser = require("sceneParser")
local Player = require("player")

local InitWorld = {}

function InitWorld.init(world)
	for i=1,10 do
		world:createStructure(Block.create(), {i*35, -i*35})
	end
	local aiShips = SceneParser.loadScene("scene1", {0, 0})
	aiShips[2] = world:createStructure(AIBlock.create(), {-35, 200})

	-- Create the anchor.
	local anchor = world:createStructure(Anchor.create(), {0, 0})

	-- Create the player.
	local playerShip = Spawn.spawnShip("BasicShip1", {0, 100})
	return {playerShip}, {anchor}, aiShips
end

return InitWorld

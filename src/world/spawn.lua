-- Spawn some ships or other objects based on a table containing all of the
-- data required to produce them. This module is designed to be called in
-- SceneParser and Saves.
local World = require("world/world")

local Spawn = {}

function Spawn.spawnObject(world, type, location, data, appendix)
	local value = World.objectTypes[type]
	local object = value(world.info, location, data, appendix)
	world:addObject(object, key)
	return object, object.isPlayer
end

return Spawn

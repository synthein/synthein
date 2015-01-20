local Block = require("block")
local Engine = require("engine")
local Gun = require("gun")
local Structure = require("structure")

local Debug = {}

function Debug.keyboard(key, globalOffsetX, globalOffsetY)
	-- Spawn a block
	if key == "u" then
		table.insert(worldStructures,
		Structure.create(Block.create(), world,
		globalOffsetX + 50, globalOffsetY - 100))
	end
	-- Spawn an engine
	if key == "i" then
		table.insert(worldStructures,
		Structure.create(Engine.create(), world,
		globalOffsetX + 112, globalOffsetY))
	end
	-- Spawn a gun
	if key == "o" then
		table.insert(worldStructures,
		Structure.create(Gun.create(), world,
		globalOffsetX + 50, globalOffsetY + 100))
	end
end

function Debug.mouse(button)
	print("not yet implemented")
end

return Debug

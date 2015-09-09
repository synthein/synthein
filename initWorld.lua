local Anchor = require("anchor")
local Block = require("block")
local Player = require("player")
local ControlBlock = require("controlBlock")
local Structure = require("structure")

local InitWorld = {}

function InitWorld.init()
	love.physics.setMeter(20) -- there are 20 pixels per meter
	local world = love.physics.newWorld()

	local worldStructures = {}
	for i=1,10 do
		worldStructures[i] = Structure.create(Block.create(), world, i*35, i*35)
	end

	-- Create the anchor.
	local anchor = Structure.create(Anchor.create(), world, -10, -10)
	anchor:addPart(Anchor.create(), 1, 0, 1)
	anchor:addPart(Anchor.create(), 0, 1, 1)
	anchor:addPart(Anchor.create(), 1, 1, 1)

	-- Create the player.
	local playerShip = Structure.create(ControlBlock.create(), world, 0, -100)
	local player1 = Player.create("player1", playerShip)

	return world, worldStructures, anchor, player1, playerShip
end

return InitWorld

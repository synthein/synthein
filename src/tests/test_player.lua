local test = require("vendor/lunatest")

local Player = require("player")
local Camera = require("camera")
local PhysicsReferences = require("world/physicsReferences")

local t = {}

function t.test_player_should_draw_world_objects()
	local drawCalls = 0
	local block = {draw = function() drawCalls = drawCalls + 1 end}
	local blockFixture = {
		getUserData = function() return block end,
		getFilterData = function() return PhysicsReferences.categories.general end,
	}

	local player = {
		camera = Camera.create(),
		world = {
			physics = {
				queryBoundingBox = function(_, _, _, _, _, fn) fn(blockFixture) end,
			}
		}
	}

	Player.drawWorldObjects(player, false)

	test.assert_equal(1, drawCalls)
end

return t

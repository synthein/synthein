local PhysicsReferences = require("world/physicsReferences")
local WorldObjects = require("world/worldObjects")
local test = require("vendor/lunatest")

local t = {}

local world = love.physics.newWorld()
local fixture = love.physics.newFixture(
  love.physics.newBody(world),
  love.physics.newCircleShape(1)
)

function t.test_valid_fixtureType()
  PhysicsReferences.setFixtureType(fixture, "general")
end

function t.test_invalid_fixtureType()
  non_real_type = "unicorn"

  test.assert_error(function()
	PhysicsReferences.setFixtureType(fixture, non_real_type)
  end,
  string.format("%q should not be a valid fixtureType", non_real_type))
end

return t

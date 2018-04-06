local test = require("vendor/lunatest")
local GameState = require("gamestates/gameState")

local t = {}

GameState.parentFunc = function() end
local testState = GameState()
testState.myFunc = function() end

function t.test_valid_function()
  test.assert_function(testState.myFunc)
end

function t.test_parent_function()
  test.assert_function(testState.parentFunc)
end

function t.test_default_function()
  test.assert_function(testState.update)
end

function t.test_invalid_function()
  test.assert_false(testState.missingFunc)
end

return t

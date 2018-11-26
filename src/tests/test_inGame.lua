local test = require("vendor/lunatest")
local InGame = require("gamestates/inGame")
local Screen = require("screen")

local t = {}

function t.test_screen_resize_should_not_crash()
	local screen = Screen()
	InGame.load({}, {}, screen)
	InGame.resize(100, 100)
end

return t

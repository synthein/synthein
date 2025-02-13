local InGame = require("gamestates/inGame")

local stub = require("tests/stub")

local t = {}

function t.test_screen_resize_should_not_crash()
	InGame.load("test-general1", {}, false, stub())
	InGame.resize(100, 100)
end

return t

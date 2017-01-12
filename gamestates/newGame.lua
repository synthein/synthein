local GameState = require("gamestates/gameState")
local InGame = require("gamestates/inGame")

local InitWorld = require("initWorld")

local NewGame = {}
setmetatable(NewGame, GameState)

function NewGame.update(dt)
	InitWorld.init("startScene", false)
	return InGame
end

return NewGame

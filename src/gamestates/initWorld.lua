local InGame = require("gamestates/inGame")

local GameState = require("gamestates/gameState")
local InitWorld = GameState()

function InitWorld.load(scene, playerHostility, ifSave)

	InitWorld.stackQueue:replace(InGame).load(scene, playerHostility, ifSave)
end

return InitWorld

local AI = require("ai")
local Camera = require("camera")
local Controls = require("controls")
local Debug = require("debugTools")
local InitWorld = require("initWorld")
local Player = require("player")
local SceneParser = require("sceneParser")
local Screen = require("screen")
local Structure = require("structure")
local World = require("world")

local GameState = require("gamestates/gameState")
local InGame = require("gamestates/inGame")

local NewGame = {}
setmetatable(NewGame, GameState)

function NewGame.update(mouseWorldX, mouseWorldY)
	InitWorld.init("startScene", false)
	return InGame
end

return NewGame

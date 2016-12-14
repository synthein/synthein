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
	compass = love.graphics.newImage("res/images/compass.png")

	world = World.create()
	Screen.createCameras()
	local ships, ifPlayer = SceneParser.loadScene("startScene", {0, 0})
	local players = {}
	for i,ship in ipairs(ships) do
		if ifPlayer[i] then
			table.insert(players, Player.create(Controls.defaults.keyboard, ship))
		end
	end

	InGame.setplayers(players)
	InGame.setWorld(world)

	Debug.setWorld(world)
	Debug.setPlayer(players[1])
	return InGame
end

return NewGame

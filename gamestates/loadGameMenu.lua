local Debug = require("debugTools")
local Camera = require("camera")
local World = require("world")
local Player = require("player")
local Structure = require("structure")
local Screen = require("screen")
local InitWorld = require("initWorld")
local AI = require

local GameState = require("gamestates/gameState")
local InGame = require("gamestates/inGame")
local SceneParser = require("sceneParser")


local LoadGameMenu = {}
setmetatable(LoadGameMenu, GameState)

function LoadGameMenu.update()
	compass = love.graphics.newImage("res/images/compass.png")

	world = World.create()
	local ships, ifPlayer = SceneParser.loadScene("syntheinSave", {0, 0}, true)
	local players = {}
	for i,ship in ipairs(ships) do
		if ifPlayer[i] then
			table.insert(players, Player.create("player1", ship))
		end
	end
	InGame.setplayers(players)
	InGame.setWorld(world)
	world:setPlayerShip(players[1].ship)

	Debug.setWorld(world)
	Debug.setPlayer(players[1])
	return InGame
end

return LoadGameMenu

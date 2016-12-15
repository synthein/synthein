local Controls = require("controls")
local Debug = require("debugTools")
local InGame = require("gamestates/inGame")
local Player = require("player")
local SceneParser = require("sceneParser")
local World = require("world")

local InitWorld = {}

function InitWorld.init(scene, ifSave)
	world = World.create()
	local ships, ifPlayer = SceneParser.loadScene(scene, {0, 0}, ifSave)
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
end

return InitWorld

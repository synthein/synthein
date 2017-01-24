local Controls = require("controls")
local Debug = require("debugTools")
local InGame = require("gamestates/inGame")
local Player = require("player")
local SceneParser = require("sceneParser")
local World = require("world")
local Structure = require("structure")

local InitWorld = {}

function InitWorld.init(scene, ifSave)
print(Structure)
	world = World.create()
	love.physics.setMeter(20) -- there are 20 pixels per meter
	Structure.setPhysics(love.physics.newWorld())

	local ships, ifPlayer = SceneParser.loadScene(scene, {0, 0}, ifSave)
	local players = {}
	for i,ship in ipairs(ships) do
		if ifPlayer[i] then
			table.insert(players, Player.create(world, Controls.defaults.keyboard, ship))
		end
		world:addObject(ship)
	end

	InGame.setplayers(players)
	InGame.setWorld(world)

	Debug.setWorld(world)
	Debug.setPlayers(players)
end

return InitWorld

local Controls = require("controls")
local Debug = require("debugTools")
local InGame = require("gamestates/inGame")
local Player = require("player")
local SceneParser = require("sceneParser")
local World = require("world")
local Structure = require("structure")
local Shot = require("shot")
local Particles = require("particles")
local AI = require("ai")

local InitWorld = {}

function InitWorld.init(scene, ifSave)
	world = World.create()
	love.physics.setMeter(20) -- there are 20 pixels per meter

	local ships, ifPlayer = SceneParser.loadScene(scene, world, {0, 0}, ifSave)
	local players = {}
	for i,ship in ipairs(ships) do
		if ifPlayer[i] then
			table.insert(AI.defaultLeaders, ship)
			table.insert(players, Player.create(world, Controls.defaults.keyboard, ship))
		end
		world:addObject(ship)
	end
	
	for i,ship in ipairs(ships) do
		if ship.corePart and ship.corePart.ai then
			local ai = ship.corePart.ai
			ai.leader = AI.defaultLeaders[ai.team]
		end
	end

	InGame.setplayers(players)
	InGame.setWorld(world)

	Debug.setWorld(world)
	Debug.setPlayers(players)
end

return InitWorld

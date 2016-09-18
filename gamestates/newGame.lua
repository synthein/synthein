local Debug = require("debugTools")
local Camera = require("camera")
local World = require("world")
local Player = require("player")
local Structure = require("structure")
local Screen = require("screen")
local InitWorld = require("initWorld")
local AI = require("ai")

local SceneParser = require("sceneParser")

local GameState = require("gamestates/gameState")
local InGame = require("gamestates/inGame")

local NewGame = {}
setmetatable(NewGame, GameState)

function NewGame.update(mouseWorldX, mouseWorldY)
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	compass = love.graphics.newImage("res/images/compass.png")
	debugmode = true

	love.physics.setMeter(20) -- there are 20 pixels per meter

	-- Instead of being global variables, these should be accessible to the
	-- states using upvalues.
	Structure.setPhysics(love.physics.newWorld())
	world = World.create()
	local ships, ifPlayer = SceneParser.loadScene("startScene", {0, 0})
	local players = {}
	for i,ship in ipairs(ships) do
		if ifPlayer[i] then
			table.insert(players, Player.create("player1", ship))
		end
		print(ship)
	end
	print(players[1].ship, players[1].ship.body)
	InGame.setplayers(players)
	Screen.createCameras()
	--camera = Camera.create()

	--camera.setX(player1.ship.body:getX())
	--camera.setY(player1.ship.body:getY())
	InGame.setWorld(world)
	world:setPlayerShip(players[1].ship)

	Debug.setWorld(world)
	Debug.setPlayer(players[1])
	return InGame
end

return NewGame

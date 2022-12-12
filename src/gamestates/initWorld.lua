local Controls = require("controls")
local Gamesave = require("gamesave")
local InGame = require("gamestates/inGame")
local Player = require("player")
local SceneParser = require("sceneParser")
local Screen = require("screen")
local World = require("world/world")

local lume = require("vendor/lume")

local GameState = require("gamestates/gameState")
local InitWorld = GameState()

function InitWorld.load(scene, playerHostility, ifSave)
	local sceneLines, message, saveName
	if ifSave then
		saveName = scene
		sceneLines, message = Gamesave.load(scene)
		if not sceneLines then
			print("Failed to load game: " .. message)
		end
		for line in sceneLines do
			local match = string.match(line, "teamhostility = (.*)")
			if match then
				playerHostility = lume.deserialize(match, true)
			elseif string.match(line, "%[scene%]") then
				break
			end
		end
	else
		local fileName = string.format("/res/scenes/%s.txt", scene)
		sceneLines = love.filesystem.lines(fileName)

	end

	local world = World(playerHostility)
	love.physics.setMeter(1) -- there are 20 pixels per meter

	local screen = Screen()

	local playerShips, maxTeam = SceneParser.loadScene(sceneLines, world, {0,0,0,0,0,0})
	-- TODO: Instead of creating players here, we should create one
	-- player per controller when the game starts up and pass those
	-- players into the world here.
	local players = {}
	for i, ship in ipairs(playerShips) do
		if i == 1 then
			table.insert(
				players,
				Player.create(world, Controls.create(), ship, screen:createCamera())
			)
		else
			local joystick = love.joystick.getJoysticks()[#players]
			if joystick then
				table.insert(
					players,
					Player.create(world, Controls.create(joystick), ship, screen:createCamera())
				)
			end
		end
	end

	if #players == 0 then
	  table.insert(players, Player.create(world, Controls.create(), nil, screen:createCamera()))
	end

	while #playerHostility < maxTeam do
		table.insert(playerHostility, {})
	end

	for i, t in ipairs(playerHostility) do
		while #t < maxTeam do
			table.insert(t, false)
		end
	end

	-- Reastablish collisions and
	world.physics:update(0)

	InitWorld.stackQueue:replace(InGame).load(world, players, screen, saveName)
end

return InitWorld

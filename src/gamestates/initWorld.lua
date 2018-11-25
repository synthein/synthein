local Controls = require("controls")
local Gamesave = require("gamesave")
local InGame = require("gamestates/inGame")
local LocationTable = require("locationTable")
local Player = require("player")
local SceneParser = require("sceneParser")
local Screen = require("screen")
local World = require("world/world")

local Tserial = require("vendor/tserial")

local GameState = require("gamestates/gameState")
local InitWorld = GameState()

function InitWorld.load(scene, playerHostility, ifSave)
	local sceneLines, message
	if ifSave then
		sceneLines, message = Gamesave.load(scene)
		if not sceneLines then
			print("Failed to load game: " .. message)
		end
		for line in sceneLines do
			local match = string.match(line, "teamhostility = (.*)")
			if match then
				playerHostility = Tserial.unpack(match, true)
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

	local playerShips = SceneParser.loadScene(sceneLines, world, LocationTable(0,0))
	local players = {}
	for _, ship in ipairs(playerShips) do
		if #players == 0 then
			table.insert(
				players,
				Player.create(world, Controls.defaults(), ship, screen:createCamera())
			)
		elseif #players > 0 then
			local joystick = love.joystick.getJoysticks()[#players]
			if joystick then
				table.insert(
					players,
					Player.create(world, Controls.defaults(joystick), ship, screen:createCamera())
				)
			end
		end
	end

	InitWorld.stackQueue:replace(InGame).load(world, players, screen)
end

return InitWorld

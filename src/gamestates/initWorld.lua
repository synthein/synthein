local Controls = require("controls")
local InGame = require("gamestates/inGame")
local Player = require("player")
local SceneParser = require("sceneParser")
local World = require("world")
local Gamesave = require("gamesave")
local Tserial = require("tserial")

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

	local playerShips = SceneParser.loadScene(sceneLines, world, {0, 0})
	local players = {}
	for _, ship in ipairs(playerShips) do
		if #players == 0 then
			table.insert(players, Player.create(world, Controls.defaults(), ship))
		elseif #players > 0 then
			local joystick = love.joystick.getJoysticks()[#players]
			if joystick then
				table.insert(players, Player.create(world, Controls.defaults(joystick), ship))
			end
		end
	end

	InitWorld.stackQueue:replace(InGame).load(world, players)
end

return InitWorld

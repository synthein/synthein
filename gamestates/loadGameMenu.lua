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

LoadGameMenu.font = love.graphics.newFont(18)
local scrollPosition = 1
local loadGameChoice
local buttons = {}

function LoadGameMenu.update()
	local files = love.filesystem.getDirectoryItems("saves")

	buttons = {}
	for i = scrollPosition, #files do
		buttonName = string.gsub(files[i], ".txt", "")
		table.insert(buttons, buttonName)
	end

	if loadGameChoice then
		compass = love.graphics.newImage("res/images/compass.png")

		world = World.create()
		local ships, ifPlayer = SceneParser.loadScene("saves/" .. loadGameChoice, {0, 0}, true)
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
end

function LoadGameMenu.draw()
	previousFont = love.graphics.getFont()
	love.graphics.setFont(LoadGameMenu.font)
	button_width = 500
	button_height = 50
	text_height = 40
	for i,button in ipairs(buttons) do
		love.graphics.setColor(100, 100, 100)
		love.graphics.rectangle("fill", (SCREEN_WIDTH - button_width)/2, 75 + 75 * i, button_width, button_height)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(buttons[i], (SCREEN_WIDTH - button_width)/2 + 10, 75 + 75 * i + button_height/2 - text_height/2, 0, 1, 1, 0, 0, 0, 0)
	end
	love.graphics.setFont(previousFont)
end

function LoadGameMenu.mousepressed(x, y, mouseButton)
	if mouseButton == 1 then
		if x < (SCREEN_WIDTH - button_width)/2 or x > (SCREEN_WIDTH + button_width)/2 then
			return MainMenu
		end
		local yRef = y - 175
		local index = math.floor(yRef/75)
		local remainder = yRef % 75

		print(index)
		print(buttons[index])

		loadGameChoice = buttons[index]
	else
		return MainMenu
	end
end

return LoadGameMenu

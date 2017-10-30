local GameState = require("gamestates/gameState")
local InGame = require("gamestates/inGame")
local Menu = require("menu")
local SceneParser = require("sceneParser")

local InitWorld = require("initWorld")

local LoadGameMenu = {}
setmetatable(LoadGameMenu, GameState)

local buttons = {}
local files = love.filesystem.getDirectoryItems("saves")
for i, fileName in pairs(files) do
	buttonName = string.gsub(fileName, ".txt", "")
	table.insert(buttons, buttonName)
end
LoadGameMenu.menu = Menu.create(love.graphics.getWidth()/2, 250, 5, buttons)

function LoadGameMenu.update(dt)
	LoadGameMenu.menu.buttons = {}
	for i, fileName in pairs(files) do
		buttonName = string.gsub(fileName, ".txt", "")
		table.insert(LoadGameMenu.menu.buttons, buttonName)
	end

	LoadGameMenu.menu:update(dt)
end

function LoadGameMenu.draw()
	LoadGameMenu.menu:draw()
end

function LoadGameMenu.mousepressed(x, y, mouseButton)
	local loadGameChoice = LoadGameMenu.menu:pressed(x, y)
	if loadGameChoice then
		InitWorld.init("saves/" .. loadGameChoice, true)
		table.insert(LoadGameMenu.stack, InGame)
	end
end

function LoadGameMenu.resize(w, h)
	LoadGameMenu.menu:resize(w, h)
end

function LoadGameMenu.mousemoved(x, y)
	LoadGameMenu.menu:mousemoved(x, y)
end

function LoadGameMenu.wheelmoved(x, y)
	LoadGameMenu.menu:wheelmoved(x, y)
end

return LoadGameMenu

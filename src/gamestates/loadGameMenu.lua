local GameState = require("gamestates/gameState")
local Menu = require("menu")

local InitWorld = require("gamestates/initWorld")

local LoadGameMenu = GameState()

local scenes = {}
local files = {}
LoadGameMenu.menu = Menu.create(250, 5, scenes)

function LoadGameMenu.load()
	scenes = {}
	files = love.filesystem.getDirectoryItems("saves")
	for _, fileName in pairs(files) do
		local buttonName = string.gsub(fileName, ".txt", "")
		table.insert(scenes, buttonName)
	end
end

function LoadGameMenu.update(dt)
	LoadGameMenu.menu.buttons = {}
	for _, fileName in pairs(files) do
		local buttonName = string.gsub(fileName, ".txt", "")
		table.insert(LoadGameMenu.menu.buttons, buttonName)
	end

	LoadGameMenu.menu:update(dt)
end

function LoadGameMenu.draw()
	LoadGameMenu.menu:draw()
end

function LoadGameMenu.keypressed(key)
	local loadGameChoice, back = LoadGameMenu.menu:keypressed(key)
	if back then
		LoadGameMenu.stackQueue:pop()
	end

	LoadGameMenu.LoadGame(loadGameChoice)
end

function LoadGameMenu.mousepressed(x, y, mouseButton)
	local loadGameChoice = LoadGameMenu.menu:pressed(x, y)
	LoadGameMenu.LoadGame(loadGameChoice)
end

function LoadGameMenu.LoadGame(index)
	local scene = scenes[index]
	if scene then
		LoadGameMenu.stackQueue:replace(InitWorld).load(scene, {}, true)
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

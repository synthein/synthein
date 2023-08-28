local GameState = require("gamestates/gameState")
local InGame = require("gamestates/inGame")
local Menu = require("menu")
local Settings = require("settings")
local log = require("log")

local LoadGameMenu = GameState()

local saveNames = {}
local saveFiles = {}
LoadGameMenu.menu = Menu.create(250, 5, saveNames)

function LoadGameMenu.load()
	saveNames = {}
	saveFiles = love.filesystem.getDirectoryItems("saves")
	for _, fileName in pairs(saveFiles) do
		local buttonName = string.gsub(fileName, ".txt", "")
		table.insert(saveNames, buttonName)
	end
end

function LoadGameMenu.update(dt)
	LoadGameMenu.menu.buttons = {}
	for _, fileName in pairs(saveFiles) do
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
	LoadGameMenu.LoadGame(LoadGameMenu.menu:getButtonAt(x, y))
end

function LoadGameMenu.LoadGame(index)
	local saveName = saveNames[index]
	local fileName = Settings.saveDir .. saveFiles[index]

	if not love.filesystem.getInfo(fileName, "file") then
		log.err("Failed to load game: File %s does not exist", fileName)
		return nil
	end

	LoadGameMenu.stackQueue:replace(InGame).load(love.filesystem.lines(fileName), {}, saveName)
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

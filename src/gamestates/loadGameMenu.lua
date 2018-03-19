local GameState = require("gamestates/gameState")
local Menu = require("menu")

local InitWorld = require("gamestates/initWorld")

local LoadGameMenu = {}
setmetatable(LoadGameMenu, GameState)

local buttons = {}
local files = love.filesystem.getDirectoryItems("saves")
for _, fileName in pairs(files) do
	local buttonName = string.gsub(fileName, ".txt", "")
	table.insert(buttons, buttonName)
end
if love.graphics then LoadGameMenu.menu = Menu.create(love.graphics.getWidth()/2, 250, 5, buttons) end

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
	if key == "escape" then
		GameState.stackPop()
	end

	local loadGameChoice = LoadGameMenu.menu:keypressed(key)
	LoadGameMenu.LoadGame(loadGameChoice)
end

function LoadGameMenu.mousepressed(x, y, mouseButton)
	local loadGameChoice = LoadGameMenu.menu:pressed(x, y)
	LoadGameMenu.LoadGame(loadGameChoice)
end

function LoadGameMenu.LoadGame(scene)
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

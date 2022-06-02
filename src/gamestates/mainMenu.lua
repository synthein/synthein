local GameState = require("gamestates/gameState")
local LoadGameMenu = require("gamestates/loadGameMenu")
local Menu = require("menu")
local NewGameMenu = require("gamestates/newGameMenu")
local ShipEditor = require("gamestates/shipEditor")
local FormationEditor = require("gamestates/formationEditor")
local SyntheinVersion = require("version")

local MainMenu = GameState()

local buttons = {NewGameMenu, LoadGameMenu, ShipEditor, FormationEditor}
local buttonNames = {"New Game", "Load Game", "Ship Editor", "Formation Editor"}
if love.graphics then
	MainMenu.font = love.graphics.newFont(36)
end
MainMenu.menu = Menu.create(250, 5, buttonNames)

function MainMenu.update(dt)
	MainMenu.menu:update(dt)
end

function MainMenu.draw()
	local previousFont = love.graphics.getFont()
	love.graphics.setFont(MainMenu.font)
	love.graphics.print("SYNTHEIN", (love.graphics.getWidth() - 200)/2 + 10, 175 , 0, 1, 1, 0, 0, 0, 0)
	MainMenu.menu:draw()
	love.graphics.setFont(previousFont)

	local major, minor, revision = love.getVersion()
	local versionString = string.format(
		"Version %s. LÖVE version %d.%d.%d.",
		SyntheinVersion, major, minor, revision
	)
	love.graphics.print(
		versionString,
		0, love.graphics.getHeight() - previousFont:getHeight()
	)
end

function MainMenu.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	local button = MainMenu.menu:keypressed(key)
	for i, name in ipairs(buttonNames) do
		if button == name then
			MainMenu.stackQueue:push(buttons[i])
		end
	end
end

function MainMenu.mousepressed(x, y, mouseButton)
	if mouseButton == 1 then
		local button = MainMenu.menu:pressed(x, y)
		for i, name in ipairs(buttonNames) do
			if button == name then
				MainMenu.stackQueue:push(buttons[i]).load()
			end
		end
	end
end

function MainMenu.resize(w, h)
	MainMenu.menu:resize(w, h)
end

function MainMenu.mousemoved(x, y)
	MainMenu.menu:mousemoved(x, y)
end

function MainMenu.wheelmoved(x, y)
	MainMenu.menu:wheelmoved(x, y)
end

return MainMenu

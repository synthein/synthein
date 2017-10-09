local GameState = require("gamestates/gameState")
local NewGameMenu = require("gamestates/newGameMenu")
local LoadGameMenu = require("gamestates/loadGameMenu")
local Menu = require("menu")

local MainMenu = {}
setmetatable(MainMenu, GameState)

MainMenu.font = love.graphics.newFont(36)
local buttons = {NewGameMenu, LoadGameMenu}
local buttonNames = {"New Game", "Load Game"}
MainMenu.menu = Menu.create(love.graphics.getWidth()/2, 250, 5, buttonNames)

function MainMenu.draw()
	local previousFont = love.graphics.getFont()
	love.graphics.setFont(MainMenu.font)
	love.graphics.print("SYNTHEIN", (SCREEN_WIDTH - 200)/2 + 10, 175 , 0, 1, 1, 0, 0, 0, 0)
	MainMenu.menu:draw()
	love.graphics.setFont(previousFont)
end

function MainMenu.mousepressed(x, y, mouseButton)
	local button = MainMenu.menu:pressed(x, y)
	if mouseButton == 1 then
		for i, name in ipairs(buttonNames) do
			if button == name then
				table.insert(MainMenu.stack, buttons[i])
			end
		end
	end
end

return MainMenu

local NewGame = require("newGame")
local LoadGameMenu = require("loadGameMenu")

local MainMenu = {}
local buttons = {NewGame, LoadGameMenu}
local buttonNames = {"New Game", "Load Game"}

function MainMenu.load()
	mainMenuFont = love.graphics.newFont(36)
end

function MainMenu.draw()
	previousFont = love.graphics.getFont()
	love.graphics.setFont(mainMenuFont)
	button_width = 500
	button_height = 50
	text_height = 40
	for i,button in ipairs(buttons) do
		love.graphics.setColor(100, 100, 100)
		love.graphics.rectangle("fill", (SCREEN_WIDTH - button_width)/2, 175 + 75 * i, button_width, button_height)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(buttonNames[i], (SCREEN_WIDTH - button_width)/2 + 10, 175 + 75 * i + button_height/2 - text_height/2, 0, 1, 1, 0, 0, 0, 0)
	end
	love.graphics.setFont(previousFont)
	return MainMenu
end

function MainMenu.update(mouseWorldX, mouseWorldY)
	return MainMenu
end

function MainMenu.keypressed(key)
	return MainMenu
end

function MainMenu.mousepressed(x, y, mouseButton)
	if mouseButton == 1 then
		if x < (SCREEN_WIDTH - button_width)/2 or x > (SCREEN_WIDTH + button_width)/2 then
			return MainMenu
		end
		local yRef = y - 175
		local index = math.floor(yRef/75)
		local remainder = yRef % 75
		if index < 1 or index > #buttons or remainder > 50 then
			return MainMenu
		end
		return buttons[index]
	else 
		return MainMenu
	end
end

function MainMenu.mousereleased(x, y, button, mouseWorldX, mouseWorldY)
	return MainMenu
end

return MainMenu

local NewGame = require("newGame")

local MainMenu = {}

function MainMenu.draw()
	button_width = 500
	button_height = 50
	text_height = 40
	love.graphics.setColor(100, 100, 100)
	love.graphics.rectangle("fill", (SCREEN_WIDTH - button_width)/2, 250, button_width, button_height)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("New Game", SCREEN_WIDTH/2, 250 + button_height/2 - text_height/2, 0, 40/12, 40/12, 0, 0, 0, 0)
	return MainMenu
end

function MainMenu.update(mouseWorldX, mouseWorldY)
	return MainMenu
end

function MainMenu.keypressed(key)
	return MainMenu
end

function MainMenu.mousepressed(mouseX, mouseY, button, mouseWorldX, mouseWorldY)
	return NewGame
end

function MainMenu.mousereleased(x, y, button, mouseWorldX, mouseWorldY)
	return MainMenu
end

return MainMenu

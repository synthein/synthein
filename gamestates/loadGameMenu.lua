local GameState = require("gamestates/gameState")

local LoadGameMenu = {}
setmetatable(LoadGameMenu, GameState)

-- Print debug info.
function LoadGameMenu.draw()
end

function LoadGameMenu.update(mouseWorldX, mouseWorldY)
end

function LoadGameMenu.keypressed(key)
	return InGame
end

function LoadGameMenu.mousepressed(mouseX, mouseY, button, mouseWorldX, mouseWorldY)
end

function LoadGameMenu.mousereleased(x, y, button, mouseWorldX, mouseWorldY)
end

return LoadGameMenu

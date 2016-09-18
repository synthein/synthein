local GameState = require("gamestates/gameState")

local LoadGameMenu = {}
setmetatable(LoadGameMenu, GameState)

function LoadGameMenu.keypressed(key)
	
	return InGame
end

return LoadGameMenu

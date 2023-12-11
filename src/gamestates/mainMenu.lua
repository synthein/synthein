local Menu = require("menu")
local SyntheinVersion = require("version")


local GameState = require("gamestates/gameState")
local MainMenu = GameState()

local buttons = {"NewGameMenu", "LoadGameMenu", "ShipEditor", "FormationEditor"}
local buttonNames = {"New Game", "Load Game", "Ship Editor", "Formation Editor"}

--TODO xordspar0 is this if still nessasary?
if love.graphics then
	MainMenu.font = love.graphics.newFont(36)
end
MainMenu.menu = Menu.create(250, 5, buttonNames)

local function gotoState(state)
	if state ~= nil then
		setGameState(buttons[state], {})
	end
end

function MainMenu.cursorpressed(cursor, control)
	if control.menu == "confirm" then
		gotoState(MainMenu.menu:getButtonAt(cursor.x, cursor.y))
	end
end

function MainMenu.cursorreleased(cursor, control)
end

function MainMenu.update(dt)
	MainMenu.menu:update(dt)
end

function MainMenu.draw()
	love.graphics.setColor(1, 1, 1)
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

	gotoState(MainMenu.menu:keypressed(key))
end

function MainMenu.mousepressed(x, y, mouseButton)
	if mouseButton == 1 then
		gotoState(MainMenu.menu:getButtonAt(x, y))
	end
end

function MainMenu.gamepadpressed(joystick, button)
	gotoState(MainMenu.menu:gamepadpressed(button))
end

function MainMenu.resize(w, h)
	MainMenu.menu:resize(w, h)
end

function MainMenu.mousemoved(cursor, control)
	MainMenu.menu:mousemoved(cursor.x, cursor.y)
end

function MainMenu.wheelmoved(x, y)
	MainMenu.menu:wheelmoved(x, y)
end

return MainMenu

local MainMenu = require("gamestates/mainMenu")
local InGame = require("gamestates/inGame")
local NewGame = require("gamestates/newGame")
local LoadGameMenu = require("gamestates/loadGameMenu")

local Debug = require("debugTools")

local state
local newState

function love.load()
	debugmode = true
	state = MainMenu
end

function love.resize(w, h)
	state.resize(w, h)
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
	if key == "f12" then debugmode = not debugmode end

	newState = state.keypressed(key)
	if newState then
		state = newState
	end
end

function love.keyreleased(key, scancode)
	state.keyreleased(key)
end

function love.mousepressed(x, y, button, istouch)
	newState = state.mousepressed(x, y, button)
	if newState then
		state = newState
	end
end
function love.mousereleased(x, y, button, istouch)
	newState = state.mousereleased(x, y, button)
	if newState then
		state = newState
	end
end

function love.wheelmoved(x, y)
	state.wheelmoved(x, y)
end

function love.update(dt)
	newState = state.update(dt)
	if newState then
		state = newState
	end
end

function love.draw()
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	state.draw()
end


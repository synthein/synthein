local Debug = require("debugTools")
local Player = require("player")
local Structure = require("structure")
local World = require("world")
local Screen = require("screen")

local MainMenu = require("gamestates/mainMenu")
local InGame = require("gamestates/inGame")
local NewGame = require("gamestates/newGame")
local LoadGameMenu = require("gamestates/loadGameMenu")

local state
local newState

function love.load()
	MainMenu.load()
	state = MainMenu
end

function love.update(dt)
	newState = state.update(dt)
	if newState then
		state = newState
	end

	if debugmode then Debug.update(mouseWorldX, mouseWorldY) end
end

function love.draw()
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	newState = state.draw()
	if newState then
		state = newState
	end
	-- Print debug info.
	if debugmode then Debug.draw() end
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
	if key == "f12" then debugmode = not debugmode end

	newState = state.keypressed(key)
	if newState then
		state = newState
	end

	if debugmode == true then
		Debug.keyboard(key, Screen.camera:getX(), Screen.camera:getY())
	end
end

function love.mousepressed(x, y, button, istouch)
	newState = state.mousepressed(x, y, button)
	if newState then
		state = newState
	end
	if debugmode == true then
		Debug.mousepressed(x, y, button, mouseWorldX, mouseWorldY)
	end
end

function love.mousereleased(x, y, button, istouch)
	newState = state.mousereleased(x, y, button)
	if newState then
		state = newState
	end

	if debugmode == true then
		Debug.mousereleased(x, y, button, mouseWorldX, mouseWorldY)
	end
end

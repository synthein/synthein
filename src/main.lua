require("class")
local GameState = require("gamestates/gameState")
local MainMenu = require("gamestates/mainMenu")

local Debug = require("debugTools")

local stack = {MainMenu}

function love.load()
	GameState.setStack(stack)

	for i, flag in ipairs(arg) do
		if flag == "--debug" then
			debugmode = true
		end
		if flag == "--test" then
			love.event.quit()
		end
	end
end

function love.resize(w, h)
	stack[#stack].resize(w, h)
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
	if key == "f12" then debugmode = not debugmode end

	stack[#stack].keypressed(key)
end

function love.keyreleased(key, scancode)
	stack[#stack].keyreleased(key)
end

function love.mousemoved(x, y)
	stack[#stack].mousemoved(x, y)
end

function love.mousepressed(x, y, button, istouch)
	stack[#stack].mousepressed(x, y, button)
end

function love.mousereleased(x, y, button, istouch)
	stack[#stack].mousereleased(x, y, button)
end

function love.joystickpressed(joystick, button)
	stack[#stack].joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	stack[#stack].joystickreleased(joystick, button)
end

function love.textinput(key)
	stack[#stack].textinput(key)
end

function love.resize(w, h)
	stack[#stack].resize(w, h)
end

function love.wheelmoved(x, y)
	stack[#stack].wheelmoved(x, y)
end

function love.update(dt)
	stack[#stack].update(dt)
end

function love.draw()
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	stack[#stack].draw()
end


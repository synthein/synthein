local StackManager = require("stackManager")
local MainMenu = require("gamestates/mainMenu")

local state

function love.load()
	state = StackManager.create(MainMenu, "stackQueue")

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
	state.resize(w, h)
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
	if key == "f12" then debugmode = not debugmode end

	state.keypressed(key)
end

function love.keyreleased(key, scancode)
	state.keyreleased(key)
end

function love.mousemoved(x, y)
	state.mousemoved(x, y)
end

function love.mousepressed(x, y, button, istouch)
	state.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button, istouch)
	state.mousereleased(x, y, button)
end

function love.joystickpressed(joystick, button)
	state.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	state.joystickreleased(joystick, button)
end

function love.textinput(key)
	state.textinput(key)
end

function love.resize(w, h)
	state.resize(w, h)
end

function love.wheelmoved(x, y)
	state.wheelmoved(x, y)
end

function love.update(dt)
	state.update(dt)
end

function love.draw()
	state.draw()
end


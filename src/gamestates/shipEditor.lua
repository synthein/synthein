local Menu = require("menu")
local PartSelector = require("partSelector")

local GameState = require("gamestates/gameState")
local ShipEditor = GameState()

local buttonNames = {"Main Menu", "Quit"}
ShipEditor.menu = Menu.create(250, 5, buttonNames)
ShipEditor.partSelector = PartSelector.create(250, 5, {"Test"})

local menuOpen = false

function ShipEditor.update(dt)
	ShipEditor.menu:update(dt)
end

function ShipEditor.draw()
	love.graphics.print(
		"wsad: Move around\n" ..
		"qe: Rotate Part\n" ..
		"f: Part Menu\n",
		5, 5)
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("line", love.graphics.getWidth()/2-10, love.graphics.getHeight()/2-10, 20, 20)
	if menuOpen == "State" then
		ShipEditor.menu:draw()
	elseif menuOpen == "Parts" then
		ShipEditor.partSelector:draw()
	end
end

function ShipEditor.keypressed(key)
	if menuOpen then
		if key == "escape" then
			menuOpen = false
		end

		if menuOpen == "Parts" then
			if key == "f" then
				menuOpen = false
			end
		end

		local button = ShipEditor.menu:keypressed(key)
		return
	end

	if key == "escape" then
		menuOpen = "State"
		return
	elseif key == "f" then
		menuOpen = "Parts"
		return
	end
end

function ShipEditor.mousepressed(x, y, mouseButton)
	if menuOpen == "State" then
		if mouseButton == 1 then
			local button = ShipEditor.menu:pressed(x, y)

			if button == "Main Menu" then
				menuOpen = false
				ShipEditor.stackQueue:pop()
			elseif button == "Quit" then
				love.event.quit()
			end
		end

	elseif menuOpen == "Parts" then

	else

	end
end

function ShipEditor.resize(w, h)
	ShipEditor.menu:resize(w, h)
end

function ShipEditor.mousemoved(x, y)
	ShipEditor.menu:mousemoved(x, y)
end

function ShipEditor.wheelmoved(x, y)
	ShipEditor.menu:wheelmoved(x, y)
end

return ShipEditor

local Menu = require("menu")
local PartSelector = require("partSelector")

local GridTable = require("gridTable")
local PartRegistry = require("world/shipparts/partRegistry")

local GameState = require("gamestates/gameState")
local ShipEditor = GameState()

local buttonNames = {"Main Menu", "Quit"}
ShipEditor.menu = Menu.create(250, 5, buttonNames)
ShipEditor.partSelector = PartSelector.create(250, 5, {"Test"})

local menuOpen = false
local gridTable = GridTable.create()
gridTable:index( 0,  0, "p")
gridTable:index( 0,  1, "b")
gridTable:index( 1,  0, "b")
gridTable:index( 0, -1, "b")
gridTable:index(-1,  0, "b")

local focusX = 0
local focusY = 0

function ShipEditor.update(dt)
	ShipEditor.menu:update(dt)
end

function ShipEditor.draw()
	local centerX = love.graphics.getWidth()/2
	local centerY = love.graphics.getHeight()/2
	local function f(k, inputs, x, y)
		love.graphics.draw(
			PartRegistry.partsList[k].image,
			centerX + (x - focusX) * 20,
			centerY + (-y - focusY) * 20,
			0, 1, 1, 10, 10, 0, 0)
	end

	gridTable:loop(f, {}, false)--(f, inputs, addSelf)f(object, inputs, x, y)
	love.graphics.print(
		"wsad: Move around\n" ..
		"qe: Rotate Part\n" ..
		"f: Part Menu\n",
		5, 5)
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("line", centerX-10, centerY-10, 20, 20)
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
	elseif key == "f" then
		menuOpen = "Parts"
	elseif key == "w" then
		focusY = focusY - 1
	elseif key == "a" then
		focusX = focusX - 1
	elseif key == "s" then
		focusY = focusY + 1
	elseif key == "d" then
		focusX = focusX + 1
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

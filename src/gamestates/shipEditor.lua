local Menu = require("menu")
local PartSelector = require("partSelector")

local GridTable = require("gridTable")
local PartRegistry = require("world/shipparts/partRegistry")
local StructureParser = require("world/structureParser")

local GameState = require("gamestates/gameState")
local ShipEditor = GameState()

local buttonNames = {"Main Menu", "Quit"}
ShipEditor.menu = Menu.create(250, 5, buttonNames)
ShipEditor.partSelector = PartSelector.create(250, 5, {"Test"})

local menuOpen = false
local gridTable = StructureParser.blueprintUnpack("g1m1g1\nb1p*b1\ne1s1e1\n")

local focusX = 0
local focusY = 0

local selectedPart = "b"

function ShipEditor.update(dt)
	ShipEditor.menu:update(dt)
end

function ShipEditor.draw()
	local centerX = love.graphics.getWidth()/2
	local centerY = love.graphics.getHeight()/2
	local function f(k, inputs, x, y)
		love.graphics.draw(
			PartRegistry.partsList[k[1]].image,
			centerX + (x - focusX) * 20,
			centerY + (-y - focusY) * 20,
			(k[2] - 1) * math.pi / 2,
			1, 1, 10, 10, 0, 0)
	end
	gridTable:loop(f, {}, false)--(f, inputs, addSelf)f(object, inputs, x, y)
	love.graphics.print(
		"wsad: Move around\n" ..
		"qe: Rotate Part\n" ..
		"space: Add Part\n" ..
		"r: Remove Part\n" ..
		"f: Part Menu\n",
		5, 5)

	love.graphics.draw(
		PartRegistry.partsList[selectedPart].image,
		centerX * 2 - 30,
		centerY * 2 - 30,
		0, 1, 1, 10, 10, 0, 0)

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

		if menuOpen == "State" then
			local button = ShipEditor.menu:keypressed(key)
		elseif menuOpen == "Parts" then
			local button = ShipEditor.partSelector:keypressed(key)
			if button then
				menuOpen = false
				selectedPart = button
			end
		end
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
	elseif key == "q" then
		if focusX ~= 0 or focusY ~= 0 then
			local t = gridTable:index(-focusX,  focusY)
			if t then
				t[2] = (t[2] + 2) % 4 + 1
			end
		end
	elseif key == "e" then
		if focusX ~= 0 or focusY ~= 0 then
			local t = gridTable:index(-focusX,  focusY)
			if t then
				t[2] = t[2] % 4 + 1
			end
		end
	elseif key == "r" then
		if focusX ~= 0 or focusY ~= 0 then
			local t = gridTable:index(focusX,  -focusY, false, true)
		end
	elseif key == "space" then
		if focusX ~= 0 or focusY ~= 0 then
			gridTable:index(focusX,  -focusY, {selectedPart, 1})
		end
	elseif key == "r" then
		if focusX ~= 0 or focusY ~= 0 then
			gridTable:index(focusX,  -focusY, false, true)
		end
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
		local part = ShipEditor.partSelector:pressed(x, y)
		if part then
			menuOpen = false
			selectedPart = part
		end
	else

	end
end

function ShipEditor.resize(w, h)
	if menuOpen == "State" then
		ShipEditor.menu:resize(w, h)
	elseif menuOpen == "Parts" then
	else
	end
end

function ShipEditor.mousemoved(x, y)
	if menuOpen == "State" then
		ShipEditor.menu:mousemoved(x, y)
	elseif menuOpen == "Parts" then
		ShipEditor.partSelector:mousemoved(x, y)
	else
	end
end

function ShipEditor.wheelmoved(x, y)
	if menuOpen == "State" then
		ShipEditor.menu:wheelmoved(x, y)
	elseif menuOpen == "Parts" then
	else
	end
end

return ShipEditor

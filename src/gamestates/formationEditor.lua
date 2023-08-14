local Menu = require("menu")
local PartSelector = require("widgets/partSelector")

local GridTable = require("gridTable")
local PartRegistry = require("world/shipparts/partRegistry")
local StructureParser = require("world/structureParser")

local GameState = require("gamestates/gameState")
local FormationEditor = GameState()

local buttonNames = {"Main Menu", "Quit"}
FormationEditor.menu = Menu.create(250, 5, buttonNames)
FormationEditor.partSelector = PartSelector.create(250, 5, {"Test"})

local menuOpen = false
local gridTable = GridTable()
local simpleShip = StructureParser.blueprintUnpack("BasicShip1")

local focusX = 0
local focusY = 0

local function generateCanvas(gridTable)
	local xLow, yLow, xHigh, yHigh = gridTable:getLimits()

	local canvas = love.graphics.newCanvas((xHigh - xLow + 1) * 20, (yHigh - yLow + 1) * 20)

	local function f(k, inputs, x, y)
		love.graphics.draw(
			PartRegistry.partsList[k[1]].image,
			(x - xLow) * 20,
			(-y + yHigh) * 20,
			(k[2] - 1) * math.pi / 2)
	end

	love.graphics.setCanvas(canvas)

	love.graphics.setColor(1,1,1)
	gridTable:loop(f, {}, false)--(f, inputs, addSelf)f(object, inputs, x, y)

	love.graphics.setCanvas()

	return canvas, -xLow * 20 + 10, yHigh * 20 + 10
end

gridTable:index(0, 0, {0, generateCanvas(StructureParser.blueprintUnpack("p*\n"))})

function FormationEditor.update(dt)
	FormationEditor.menu:update(dt)
end

function FormationEditor.draw()
	local centerX = love.graphics.getWidth()/2
	local centerY = love.graphics.getHeight()/2

	local function f(ship, inputs, x, y)
		local angle, canvas, cX, cY = unpack(ship)
		love.graphics.draw(
			canvas,
			centerX + (x - focusX) * 20,
			centerY + (y + focusY) * 20,
			angle * math.pi / 2,
			1, 1, cX, cY, 0, 0)
	end

	gridTable:loop(f, {}, false)--(f, inputs, addSelf)f(object, inputs, x, y)

	love.graphics.print(
		"wsad: Move around\n" ..
		"qe: Rotate Ship\n" ..
		"space: Add Ship\n" ..
		"r: Remove Ship\n" ..
		"f: Part Menu\n",
		5, 5)

	love.graphics.setColor(1,1,1)
	if menuOpen == "State" then
		FormationEditor.menu:draw()
	elseif menuOpen == "Parts" then
		FormationEditor.partSelector:draw()
	end
end

function FormationEditor.keypressed(key)
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
			local button = FormationEditor.menu:keypressed(key)
			button = buttonNames[button]

			if button == "Main Menu" then
				menuOpen = false
				FormationEditor.stackQueue:pop()
			elseif button == "Quit" then
				love.event.quit()
			end
		elseif menuOpen == "Parts" then
			local button = FormationEditor.partSelector:keypressed(key)
			if button then
				menuOpen = false
			end
		end
		return
	end

	if key == "escape" then
		menuOpen = "State"
	elseif key == "f" then
		menuOpen = "Parts"
	elseif key == "w" then
		focusY = focusY + 1
	elseif key == "a" then
		focusX = focusX - 1
	elseif key == "s" then
		focusY = focusY + 1
	elseif key == "d" then
		focusX = focusX - 1
	elseif key == "q" then
		if focusX ~= 0 or focusY ~= 0 then
			local t = gridTable:index(focusX, -focusY)
			if t then
				t[1] = (t[1] + 3) % 4
			end
		end
	elseif key == "e" then
		if focusX ~= 0 or focusY ~= 0 then
			local t = gridTable:index(focusX, -focusY)
			if t then
				t[1] = (t[1] + 1) % 4
			end
		end
	elseif key == "space" then
		if focusX ~= 0 or focusY ~= 0 then
			gridTable:index(focusX,  -focusY, {0, generateCanvas(simpleShip)})
		end
	elseif key == "r" then
		if focusX ~= 0 or focusY ~= 0 then
			gridTable:index(focusX,  -focusY, false, true)
		end
	end
end

-- TODO: Make menu work with keyboard and controller
function FormationEditor.mousepressed(x, y, mouseButton)
	if menuOpen == "State" then
		if mouseButton == 1 then
			local button = FormationEditor.menu:getButtonAt(x, y)

			if button == "Main Menu" then
				menuOpen = false
				FormationEditor.stackQueue:pop()
			elseif button == "Quit" then
				love.event.quit()
			end
		end

	elseif menuOpen == "Parts" then
		local part = FormationEditor.partSelector:pressed(x, y)
		if part then
			menuOpen = false
			selectedPart = part
		end
	else

	end
end

function FormationEditor.resize(w, h)
	if menuOpen == "State" then
		FormationEditor.menu:resize(w, h)
	elseif menuOpen == "Parts" then
	else
	end
end

function FormationEditor.mousemoved(x, y)
	if menuOpen == "State" then
		FormationEditor.menu:mousemoved(x, y)
	elseif menuOpen == "Parts" then
		FormationEditor.partSelector:mousemoved(x, y)
	else
	end
end

function FormationEditor.wheelmoved(x, y)
	if menuOpen == "State" then
		FormationEditor.menu:wheelmoved(x, y)
	elseif menuOpen == "Parts" then
	else
	end
end

return FormationEditor

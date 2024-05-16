local Menu = require("menu")
local PartSelector = require("widgets/partSelector")

local GridTable = require("gridTable")
local PartRegistry = require("world/shipparts/partRegistry")
local StructureParser = require("world/structureParser")

local GameState = require("gamestates/gameState")
local FormationEditor = GameState()

local buttonNames = {"Main Menu", "Quit"}
FormationEditor.menu = Menu.create(250, 5, buttonNames)

--TODO replace with ship selector
--FormationEditor.partSelector = PartSelector.create(250)

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

function FormationEditor.cursorpressed(cursor, control)
end

function FormationEditor.cursorreleased(cursor, control)
end

function FormationEditor.pressed(control)
	if menuOpen then
		if control.menu == "cancel" then
			menuOpen = false
		end

		if menuOpen == "State" then
			local button = FormationEditor.menu:keypressed(key)
			button = buttonNames[button]

			if button == "Main Menu" then
				menuOpen = false
				setGameState("MainMenu")
			elseif button == "Quit" then
				love.event.quit()
			end
		--TODO replace with ship selector
		--[[elseif menuOpen == "Parts" then
			if control.editor == "pallet" then
				menuOpen = false
			end
			local button = FormationEditor.partSelector:keypressed(key)
			if button then
				menuOpen = false
			end]]
		end
		return
	else
		if control.editor == "gameMenu" then
			menuOpen = "State"
		elseif control.editor == "pallet" then
			--TODO replace with ship selector
			--menuOpen = "Parts"
		elseif control.editor == "up" then
			focusY = focusY - 1
		elseif control.editor == "down" then
			focusY = focusY + 1
		elseif control.editor == "left" then
			focusX = focusX - 1
		elseif control.editor == "right" then
			focusX = focusX + 1
		elseif control.editor == "ccw" then
			if focusX ~= 0 or focusY ~= 0 then
				local t = gridTable:index(focusX, -focusY)
				if t then
					t[1] = (t[1] + 3) % 4
				end
			end
		elseif control.editor == "cw" then
			if focusX ~= 0 or focusY ~= 0 then
				local t = gridTable:index(focusX, -focusY)
				if t then
					t[1] = (t[1] + 1) % 4
				end
			end
		elseif control.editor == "add" then
			if focusX ~= 0 or focusY ~= 0 then
				gridTable:index(focusX,  -focusY, {0, generateCanvas(simpleShip)})
			end
		elseif control.editor == "remove" then
			if focusX ~= 0 or focusY ~= 0 then
				gridTable:index(focusX,  -focusY, false, true)
			end
		end
	end
end

function FormationEditor.released(control)
end

--[[

function .mousemoved(cursor, control)
end

function .wheelmoved(cursor, control)
end

function .gamepadpressed(joystick, button)
end

function .gamepadreleased(joystick, button)
end

function .joystickpressed(joystick, button)
end

function .joystickreleased(joystick, button)
end

function .textinput(key)
end

--]]

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
		"i: Part Menu\n",
		5, 5)

	love.graphics.setColor(1,1,1)
	if menuOpen == "State" then
		FormationEditor.menu:draw()
	--elseif menuOpen == "Parts" then
	--TODO replace with ship selector
		--FormationEditor.partSelector:draw()
	end
end

-- TODO: Make menu work with keyboard and controller
function FormationEditor.mousepressed(x, y, mouseButton)
	if menuOpen == "State" then
		if mouseButton == 1 then
			local button = FormationEditor.menu:getButtonAt(x, y)

			if button == "Main Menu" then
				menuOpen = false
				setGameState("MainMenu")
			elseif button == "Quit" then
				love.event.quit()
			end
		end

	--elseif menuOpen == "Parts" then
		--TODO replace with ship selector
		--[[local part = FormationEditor.partSelector:pressed(x, y)
		if part then
			menuOpen = false
			selectedPart = part
		end]]
	else

	end
end

function FormationEditor.resize(w, h)
	if menuOpen == "State" then
		FormationEditor.menu:resize(w, h)
	--elseif menuOpen == "Parts" then
		--TODO replace with ship selector
	else
	end
end

function FormationEditor.mousemoved(x, y)
	if menuOpen == "State" then
		FormationEditor.menu:mousemoved(x, y)
	--elseif menuOpen == "Parts" then
		--TODO replace with ship selector
		--FormationEditor.partSelector:mousemoved(x, y)
	else
	end
end

function FormationEditor.wheelmoved(x, y)
	if menuOpen == "State" then
		FormationEditor.menu:wheelmoved(x, y)
	--elseif menuOpen == "Parts" then
		--TODO replace with ship selector
	else
	end
end

return FormationEditor

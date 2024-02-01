local Menu = require("menu")
local SaveMenu = require("saveMenu")
local LoadMenu = require("loadMenu")
local PartSelector = require("widgets/partSelector")

local GridTable = require("gridTable")
local PartRegistry = require("world/shipparts/partRegistry")
local StructureParser = require("world/structureParser")

local GameState = require("gamestates/gameState")
local ShipEditor = GameState()

local buttonNames = {"Save Blueprint", "Load Blueprint", "Main Menu", "Quit"}
ShipEditor.menu = Menu.create(250, 5, buttonNames)
ShipEditor.saveMenu = SaveMenu("blueprints/")
ShipEditor.loadMenu = LoadMenu("blueprints")
ShipEditor.partSelector = PartSelector.create(250)

local menuOpen = false
local gridTable = StructureParser.blueprintUnpack("g1m1g1\nb1p*b1\ne1s1e1\n")

local focusX = 0
local focusY = 0

local selectedPart = "b"


function ShipEditor.cursorpressed(cursor, control)
	if menuOpen == "State" then
		if mouseButton == 1 then
			local button = ShipEditor.menu:pressed(x, y)

			if button == "Save Blueprint" then
				menuOpen = "Save"
				ShipEditor.saveMenu:resetName()
			elseif button == "Load Blueprint" then
				menuOpen = "Load"
				ShipEditor.loadMenu:reset()
			elseif button == "Main Menu" then
				menuOpen = false
				setGameState("MainMenu")
			elseif button == "Quit" then
				love.event.quit()
			end
		end
	elseif menuOpen == "Save" then
		menuOpen = false
	elseif menuOpen == "Load" then
		local file = ShipEditor.loadMenu:pressed(x, y)
		if file then
			gridTable = StructureParser.blueprintUnpack(love.filesystem.read(file))
			menuOpen = false
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

function ShipEditor.cursorreleased(cursor, control)
end

function ShipEditor.pressed(control)
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

			--TODO add menu selection code here
			-- mabye create a function for handling both key and mosue presses
		elseif menuOpen == "Save" then
			if key == "return" then
				Success, Message = ShipEditor.saveMenu:saveFile(
					StructureParser.blueprintPack(gridTable))
				if not Success then
					print("shipEditor save file ERROR:")
					print(Message)
				end
				menuOpen = false
			else
				ShipEditor.saveMenu:keypressed(key)
			end
		elseif menuOpen == "Load" then
			local file = ShipEditor.loadMenu:keypressed(key)
			if file then
				gridTable = StructureParser.blueprintUnpack(love.filesystem.read(file))
				menuOpen = false
			end
		elseif menuOpen == "Parts" then
			local button = ShipEditor.partSelector:pressed(control)
			if button then
				menuOpen = false
				selectedPart = button
			end
		end
		return
	end

	if control.editor == "stateMenu" then
		menuOpen = "State"
	elseif control.editor == "pallet" then
		menuOpen = "Parts"
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
			local t = gridTable:index(focusX,  -focusY)
			if t then
				t[2] = (t[2] + 2) % 4 + 1
			end
		end
	elseif control.editor == "cw" then
		if focusX ~= 0 or focusY ~= 0 then
			local t = gridTable:index(focusX,  -focusY)
			if t then
				t[2] = t[2] % 4 + 1
			end
		end
	elseif control.editor == "add" then
		if focusX ~= 0 or focusY ~= 0 then
			gridTable:index(focusX,  -focusY, {selectedPart, 1})
		end
	elseif control.editor == "remove" then
		if focusX ~= 0 or focusY ~= 0 then
			gridTable:index(focusX,  -focusY, false, true)
		end
	end
end

function ShipEditor.released(control)
end

--[[
function .gamepadpressed(joystick, button)
end

function .gamepadreleased(joystick, button)
end

function .joystickpressed(joystick, button)
end

function .joystickreleased(joystick, button)
end

--]]

function ShipEditor.mousemoved(cursor, control)
	if menuOpen == "State" then
		ShipEditor.menu:mousemoved(unpack(cursor))
	elseif menuOpen == "Save" then
	elseif menuOpen == "Load" then
		ShipEditor.loadMenu:mousemoved(unpack(cursor))
	elseif menuOpen == "Parts" then
		ShipEditor.partSelector:mousemoved(cursor)
	else
	end
end

-- function .wheelmoved(cursor, control)
function ShipEditor.wheelmoved(x, y)
	if menuOpen == "State" then
		ShipEditor.menu:wheelmoved(x, y)
	elseif menuOpen == "Save" then
	elseif menuOpen == "Load" then
		ShipEditor.loadMenu:wheelmoved(x, y)
	elseif menuOpen == "Parts" then
	else
	end
end

function ShipEditor.textinput(key)
	ShipEditor.saveMenu:textinput(key)
end

function ShipEditor.update(dt)
	if menuOpen == "State" then
		ShipEditor.menu:update(dt)
	elseif menuOpen == "Save" then
	elseif menuOpen == "Load" then
		ShipEditor.loadMenu:update(dt)
	elseif menuOpen == "Parts" then
	else
	end
end

function ShipEditor.resize(w, h)
	if menuOpen == "State" then
		ShipEditor.menu:resize(w, h)
	elseif menuOpen == "Save" then
	elseif menuOpen == "Load" then
		ShipEditor.loadMenu:resize(w, h)
	elseif menuOpen == "Parts" then
	else
	end
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
	elseif menuOpen == "Save" then
		ShipEditor.saveMenu:draw()
	elseif menuOpen == "Load" then
		ShipEditor.loadMenu:draw()
	elseif menuOpen == "Parts" then
		ShipEditor.partSelector:draw()
	end
end

return ShipEditor

local Building = require("building")
local Util = require("util")
local World = require("world")
local Screen = require("screen")

local Player = {}
Player.__index = Player

function Player.create(controls, structure)
	local self = {}
	setmetatable(self, Player)

	self.ship = structure

	self.controls = controls

	self.selection = nil
	self.cancelKeyDown = false
	self.selectionKeyDown = false
	self.isBuilding = false
	self.isRemoving = false
	self.partX = nil
	self.partY = nil
	self.cursorX = 0
	self.cursorY = 0
	self.build = nil

	return self
end

function Player:handleInput()
	-----------------------
	----- Cancel/Quit -----
	-----------------------
	if not self.cancelKeyDown then
		-- Open the pause menu.
		if menuOpen then
			if love.keyboard.isDown(self.controls.cancel) then
				menuOpen = false
				self.cancelKeyDown = true
			end

		elseif love.keyboard.isDown(self.controls.cancel) then
			-- If selection mode is not enabled, quit the game when the cancel key
			-- is pressed.
			if not self.selection then
				menuOpen = true
			else
				-- If selection mode is enabled, just leave selection mode.
				self.selection = nil
			end
			self.cancelKeyDown = true
		end

	elseif not love.keyboard.isDown(self.controls.cancel) then
		self.cancelKeyDown = false
	end

	-----------------------
	---- Ship commands ----
	-----------------------
	local orders = {}

	if self.controls.joystick then
		local joystick = self.controls.joystick

		if joystick:isGamepadDown(self.controls.forward) then
			table.insert(orders, "forward")
		end
		if joystick:isGamepadDown(self.controls.back) then
			table.insert(orders, "back")
		end
		if joystick:isGamepadDown(self.controls.left) then
			table.insert(orders, "left")
		end
		if joystick:isGamepadDown(self.controls.right) then
			table.insert(orders, "right")
		end
		if joystick:isGamepadDown(self.controls.strafeLeft) then
			table.insert(orders, "strafeLeft")
		end
		if joystick:isGamepadDown(self.controls.strafeRight) then
			table.insert(orders, "strafeRight")
		end
		if joystick:isGamepadDown(self.controls.shoot) then
			table.insert(orders, "shoot")
		end
	else
		if love.keyboard.isDown(self.controls.forward) then
			table.insert(orders, "forward")
		end
		if love.keyboard.isDown(self.controls.back) then
			table.insert(orders, "back")
		end
		if love.keyboard.isDown(self.controls.left) then
			table.insert(orders, "left")
		end
		if love.keyboard.isDown(self.controls.right) then
			table.insert(orders, "right")
		end
		if love.keyboard.isDown(self.controls.strafeLeft) then
			table.insert(orders, "strafeLeft")
		end
		if love.keyboard.isDown(self.controls.strafeRight) then
			table.insert(orders, "strafeRight")
		end
		if love.keyboard.isDown(self.controls.shoot) then
			table.insert(orders, "shoot")
		end
	end

	if self.ship then
		if self.ship.corePart then
			self.ship.corePart:setOrders(orders)
		else
			self.ship = nil
		end
	end
end

function Player:mousepressed(button)
	cursorX, cursorY = Screen.getCursorCoords(self.cursorX, self.cursorY)
	if button == 1 then
		if not self.build then
			local team
			if self.ship and self.ship.corePart then
				team = self.ship.corePart:getTeam()
			end
			if team then
				self.build = Building.create(world, team)
			end
		end
			if self.build and self.build:pressed(cursorX, cursorY) then
				self.build = nil
			end

	end
	if button == 2 then
		if self.build then
			self.build = nil
		else
			local team
			if self.ship and self.ship.corePart then
				team = self.ship.corePart:getTeam()
			end
			local structure, part = world:getStructure(cursorX, cursorY)
			local structureTeam
			if structure and structure.corePart then
				structureTeam = structure.corePart:getTeam()
			end
			if structureTeam and team and structureTeam ~= team then
				structure = nil
				part = nil
			end
			if structure and part then
				world:removeSection(structure, part)
			end
		end
	end
end

function Player:mousereleased(button)
	cursorX, cursorY = Screen.getCursorCoords(self.cursorX, self.cursorY)
	if button == 1 then
		if self.build then
			if self.build:released(cursorX, cursorY) then
				self.build = nil
			end
		end
	end
end

function Player:draw()
	cursorX, cursorY = Screen.getCursorCoords(self.cursorX, self.cursorY)
	if self.build then
		self.build:draw(cursorX, cursorY)
	end
end

return Player

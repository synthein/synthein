local Building = require("building")
local Util = require("util")
local World = require("world")
local Screen = require("screen")

local Player = {}
Player.__index = Player

function Player.create(type, structure)
	local self = {}
	setmetatable(self, Player)

	self.ship = structure

	if type == "player1" then
		self.forward = "w"
		self.back = "s"
		self.left = "a"
		self.right = "d"
		self.strafeLeft = "q"
		self.strafeRight = "e"
		self.selectPrevious = "v"
		self.selectNext = "c"
		self.removePart = "x"
		self.confirm = "return"
		self.cancel = "escape"
		self.shoot = "space"
	elseif type =="player2" then
	end

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
			if love.keyboard.isDown(self.cancel) then
				menuOpen = false
				self.cancelKeyDown = true
			end

		elseif love.keyboard.isDown(self.cancel) then
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

	elseif not love.keyboard.isDown(self.cancel) then
		self.cancelKeyDown = false
	end

	-----------------------
	---- Ship commands ----
	-----------------------
	local orders = {}

	if love.keyboard.isDown(self.forward) then
		table.insert(orders, "forward")
	end
	if love.keyboard.isDown(self.back) then
		table.insert(orders, "back")
	end
	if love.keyboard.isDown(self.left) then
		table.insert(orders, "left")
	end
	if love.keyboard.isDown(self.right) then
		table.insert(orders, "right")
	end
	if love.keyboard.isDown(self.strafeLeft) then
		table.insert(orders, "strafeLeft")
	end
	if love.keyboard.isDown(self.strafeRight) then
		table.insert(orders, "strafeRight")
	end
	if love.keyboard.isDown(self.shoot) then
		table.insert(orders, "shoot")
	end

	self.ship.corePart:setOrders(orders)
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

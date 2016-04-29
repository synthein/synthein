local Building = require("building")
local Util = require("util")
local World = require("world")

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
	self.build = nil

	return self
end

-- TODO: find a better way to get the global offset
function Player:handleInput(globalOffsetX, globalOffsetY)
	-----------------------
	----- Cancel/Quit -----
	-----------------------
	if not self.cancelKeyDown then
		-- Prompt before quitting.
		if quitting then
			if love.keyboard.isDown(self.confirm) or love.keyboard.isDown("y") then
				love.event.quit()
			end
			if love.keyboard.isDown(self.cancel) or love.keyboard.isDown("n") then
				quitting = false
				self.cancelKeyDown = true
			end

		elseif love.keyboard.isDown(self.cancel) then
			-- If selection mode is not enabled, quit the game when the cancel key
			-- is pressed.
			if not self.selection then
				quitting = true
				-- If selection mode is enabled, just leave selection mode.
			else
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

	self.ship:command(orders)
end

function Player:mousepressed(mouseX, mouseY, button)
	-- Convert the mouseX and Y coordinates to coordinates in the world.
	local mouseWorldX = mouseX - SCREEN_WIDTH/2 + globalOffsetX
	local mouseWorldY = mouseY - SCREEN_HEIGHT/2 + globalOffsetY

	if button == 1 then
		if not self.build then
			self.build = Building.create(world)
		end
			if self.build:pressed(mouseWorldX, mouseWorldY) then
				self.build = nil
			end
		
	end
	if button == 2 then
		local structure, part = world:getStructure(mouseWorldX, mouseWorldY)
		if structure and part then
			world:removeSection(structure, part)
		end
	end
end

function Player:mousereleased(mouseX, mouseY, button)
	-- Convert the mouseX and Y coordinates to coordinates in the world.
	local mouseWorldX = mouseX - SCREEN_WIDTH/2 + globalOffsetX
	local mouseWorldY = mouseY - SCREEN_HEIGHT/2 + globalOffsetY

	if button == 1 then
		if self.build then
			if self.build:released(mouseWorldX, mouseWorldY) then
				self.build = nil
			end
		end
	end
end

function Player:draw(globalOffsetX, globalOffsetY, mouseWorldX, mouseWorldY)
	if self.build then
		self.build:draw(globalOffsetX, globalOffsetY, mouseWorldX, mouseWorldY)
	end
end

return Player


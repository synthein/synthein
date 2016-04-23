local Selection = require("selection")
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
	elseif type =="player2" then
	elseif type == "AI" then
	end

	self.selection = nil
	self.cancelKeyDown = false
	self.selectionKeyDown = false
	self.isBuilding = false
	self.isRemoving = false
	self.partX = nil
	self.partY = nil

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

	self.ship:command(orders)

	-----------------------
	-- Building commands --
	-----------------------

	--	TODO: remove these (use mouse controls instead)
	-- If the one of the selection keys is already down, don't react to them.
	if not self.selectionKeyDown then

		if love.keyboard.isDown(self.selectPrevious) or
		   love.keyboard.isDown(self.selectNext) or
		   love.keyboard.isDown(self.confirm) or
		   love.keyboard.isDown(self.removePart) then
			-- If select mode is not enabled, enable it.
			if not self.selection then
				self.selection = Selection.enable(worldStructures, self.ship,
				                                  anchor)

			-- If selection mode is enabled, then we can send commands to
			-- self.selection.
			else
				if love.keyboard.isDown(self.selectPrevious) then
					self.selection:previous()
				end

				if love.keyboard.isDown(self.selectNext) then
					self.selection:next()
				end

				if love.keyboard.isDown(self.confirm) then
					if self.selection:confirm() == 1 then
						-- Disable selection mode when we are done.
						self.selection = nil
					end
				end
			end
			-- Lock out the selection keys until they are released.
			self.selectionKeyDown = true

			if not self.isremoving and 
				   love.keyboard.isDown(self.removePart) then
				self.isremoving = true
			end
		end

	-- Once the selection keys are released, start listening for them again.
	elseif not love.keyboard.isDown(self.selectPrevious) and
	       not love.keyboard.isDown(self.selectNext) and
	       not love.keyboard.isDown(self.confirm) then
		self.selectionKeyDown = false
	end
end

function Player:build(mouseWorldX, mouseWorldY)
	if not self.isBuilding then
		self.isBuilding = true

		self.annexee, self.annexeePart, self.annexeePartSideClicked, 
		self.annexeeIndex = world:getWorldStructure(mouseWorldX, mouseWorldY)

		if not self.annexee then
			self.isBuilding = false
		end

	else
		self.structure, self.structurePart, self.structurePartSideClicked = 
		world:getStructure(mouseWorldX,mouseWorldY)
		if self.structure and self.annexee and
		   self.structure ~= self.annexee then
			world:annex(self.annexee, self.annexeePart, self.annexeePartSideClicked, annexeeIndex,
						self.structure, self.structurePart, self.structurePartSideClicked)
		end
		self.structure, self.annexee = nil
		self.isBuilding = false
	end
end

function Player:mousepressed(mouseX, mouseY, button)
	-- Convert the mouseX and Y coordinates to coordinates in the world.
	local mouseWorldX = mouseX - SCREEN_WIDTH/2 + globalOffsetX
	local mouseWorldY = mouseY - SCREEN_HEIGHT/2 + globalOffsetY

	if button == 1 then
		self:build(mouseWorldX, mouseWorldY)
	end
	if button == 2 then
		world:removeSection(world:getStructure(mouseWorldX, mouseWorldY))
	end
end

function Player:draw(globalOffsetX, globalOffsetY)
	self.ship:draw(globalOffsetX, globalOffsetY)
	if self.selection then
		self.selection:draw(globalOffsetX, globalOffsetY)
	end
end

return Player


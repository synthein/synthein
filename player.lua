local Selection = require("selection")

Player = {}
Player.__index = Player

function Player.create(type, structure)
	local self = {}
	setmetatable(self, Player)

	self.ship = structure

	if type == "player1" then
		self.forward = "up"
		self.back = "down"
		self.left = "left"
		self.right = "right"
		self.strafeLeft = "a"
		self.strafeRight = "s"
		self.selectPrevious = "d"
		self.selectNext = "c"
		self.confirmSelection = "return"
		self.cancel = "escape"
	elseif type =="player2" then
	elseif type == "AI" then
	end

	self.selection = nil
	self.cancelKeyDown = false
	self.selectionKeyDown = false

	return self
end

function Player:handleInput()
	local orders = {}

	-- Ship commands
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

	if not self.cancelKeyDown and love.keyboard.isDown(self.cancel) then
		-- If selection mode is not enabled, quit the game when the cancel key
		-- is pressed.
		if not self.selection then
			love.event.push("quit")

		-- If selection mode is enabled, just leave selection mode.
		else
			self.selection = nil
		end

		self.cancelKeyDown = true
	elseif not love.keyboard.isDown(self.cancel) then
		self.cancelKeyDown = false
	end

	-- Selection commands

	-- If the one of the selection keys is already down, don't react to them.
	if not self.selectionKeyDown then

		if love.keyboard.isDown(self.selectPrevious) or
		   love.keyboard.isDown(self.selectNext) or
		   love.keyboard.isDown(self.confirmSelection) then
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

				if love.keyboard.isDown(self.confirmSelection) then
					if self.selection:confirm() == 1 then
						-- Disable selection mode when we are done.
						self.selection = nil
					end
				end
			end
			-- Lock out the selection keys until they are released.
			self.selectionKeyDown = true
		end

	-- Once the selection keys are released, start listening for them again.
	elseif not love.keyboard.isDown(self.selectPrevious) and
	       not love.keyboard.isDown(self.selectNext) and
	       not love.keyboard.isDown(self.confirmSelection) then
		self.selectionKeyDown = false
	end
end

function Player:draw(globalOffsetX, globalOffsetY)
	self.ship:draw()
	if self.selection then
		self.selection:draw(globalOffsetX, globalOffsetY)
	end
end

return Player

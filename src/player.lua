local Controls = require("controls")
local Screen = require("screen")
local Selection = require("selection")

local Player = {}
Player.__index = Player

function Player.create(world, controls, structure)
	local self = {}
	setmetatable(self, Player)

	self.world = world
	self.controls = controls
	self.ship = structure
	self.camera = Screen.createCamera()
	self.selected = Selection.create(world, self.ship.corePart:getTeam(),
									self.camera)

	self.selection = nil
	self.cancelKeyDown = false
	self.selectionKeyDown = false
	self.isBuilding = false
	self.isRemoving = false
	self.partX = nil
	self.partY = nil
	self.cursorX = 0
	self.cursorY = 0

	return self
end

function Player:handleInput(menuOpen)

	if self.ship then
		self.camera:setX(self.ship.body:getX())
		self.camera:setY(self.ship.body:getY())
	end

	-----------------------
	----- Cancel/Quit -----
	-----------------------
	if not self.cancelKeyDown then
		-- Open the pause menu.
		if menuOpen then
			if Controls.isDown(self.controls.cancel) then
				menuOpen = false
				self.cancelKeyDown = true
			end

		elseif Controls.isDown(self.controls.cancel) then
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

	elseif not Controls.isDown(self.controls.cancel) then
		self.cancelKeyDown = false
	end

	
	-----------------------
	----- Set Cursor  -----
	-----------------------
	self.cursorX = Controls.setCursor(self.controls.cursorX, self.cursorX)
	self.cursorY = Controls.setCursor(self.controls.cursorY, self.cursorY)
	self.cursorX, self.cursorY = self.camera:limitCursor(self.cursorX,
														 self.cursorY)
	
	-----------------------
	---- Ship commands ----
	-----------------------
	local orders = Controls.getOrders(self.controls)

	if self.ship then
		if self.ship.corePart then
			self.ship.corePart:setOrders(orders)
		else
			self.ship = nil
		end
	end
	return menuOpen
end

function Player:buttonpressed(source, button)
	local order = Controls.testPressed(self.controls, source, button)

	if not order then
		return
	end

	cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
	if order == "build" then
		self.selected:pressed(cursorX, cursorY)

	elseif order == "destroy" then
		if self.build then
			self.build = nil
		else
			if not self.ship or not self.ship.corePart then
				return
			end
			local team = self.ship.corePart:getTeam()
			local structure, part, partSide = world:getObject(cursorX, cursorY,
															  "structures")
			
			if not structure or not structure.corePart or not part then
				return
			end
			local structureTeam = structure.corePart:getTeam()
			if structureTeam and structureTeam ~= team then
				return
			end

			structure:disconnectPart(part)
		end

	elseif order == "zoomIn" then
		self.camera:adjustZoom(1)
	elseif order == "zoomOut" then
		self.camera:adjustZoom(-1)
	end
end

function Player:buttonreleased(source, button)
	local order = Controls.testReleased(self.controls, source, button)

	cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
	if order == "build" then
		self.selected:released(cursorX, cursorY)
	end
end

function Player:draw()
	if self.ship then
		self.camera:setX(self.ship.body:getX())
		self.camera:setY(self.ship.body:getY())
	end

	local callbackData = {}
	local a, b, c, d = self.camera:getWorldBoarder()

	function callback(fixture)
		table.insert(callbackData, fixture:getUserData())
		return true
	end

	self.world.physics:queryBoundingBox(a, b, c, d, callback)

	for drawlayer, object in ipairs(callbackData) do
		object:draw(self.camera)
	end

	cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
	if self.selected then
		self.selected:draw(cursorX, cursorY)
	end

	local point
	if self.ship and self.ship.corePart and self.ship.corePart.leader then
		point = {self.ship.corePart.leader:getLocation()}
	else
		point = {0,0}
	end

	self.camera:drawExtras(point, {self.cursorX, self.cursorY})
end

return Player

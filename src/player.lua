local Controls = require("controls")
local Screen = require("screen")
local Selection = require("selection")
local Menu = require("menu")
local PartRegistry = require("shipparts/partRegistry")

local Player = {}
Player.__index = Player

function Player.create(world, controls, structure)
	local self = {}
	setmetatable(self, Player)

	self.world = world
	self.controls = controls
	self.ship = structure
print("player wrap")
	self.camera = Screen.createCamera()
	self.drawWorldObjects = self.camera.wrap(Player.drawWorldObjects, true)

	self.selected = Selection.create(world, self.ship.corePart:getTeam(),
									self.camera)
	self.menu = nil
	self.menuOpen = false
	self.closeMenu = false
	self.openMenu = false
	self.menuButtonNames = {"Block", "Engine", "Gun", "AI", "Enemy"}

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

function Player:handleInput()

	if self.ship then
		self.camera:setX(self.ship.body:getX())
		self.camera:setY(self.ship.body:getY())
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
end

function Player:buttonpressed(source, button)
	local menuButton = Controls.test("menu", self.controls, source, button)
	local order = Controls.test("pressed", self.controls, source, button)

	if self.menuOpen then
		if not menuButton then
			return
		end
		if menuButton == "cancel" then
			-- Exit menu if canel is pressed.
			self.closeMenu = true
		end
	elseif self.menu then
		if not menuButton then
			return
		end

		if menuButton == "cancel" then
			-- Exit menu if canel is pressed.
			self.menu = nil
		elseif menuButton == "confirm" then
			local buttonInt = self.menu:getButtonAt(self.cursorX, self.cursorY)
			local button = self.menuButtonNames[buttonInt]

			local cameraX, cameraY = self.camera:getPosition()
			local part, location
			if button == "Block" then
				-- Spawn a block
				location = {cameraX, cameraY + 5}
				part = PartRegistry.createPart('b')
			elseif button == "Engine" then
				-- Spawn an engine
				location = {cameraX + 5, cameraY + 5}
				part = PartRegistry.createPart('e')
			elseif button == "Gun" then
				-- Spawn a gun
				location = {cameraX - 5, cameraY + 5}
				part = PartRegistry.createPart('g')
			elseif button == "AI" then
				--Spawn an AI
				location = {cameraX - 10, cameraY + 10}
				part = PartRegistry.createPart('a', {self.ship:getTeam()})
			elseif button == "Enemy" then
				--Spawn an Enemy
				location = {cameraX + 10, cameraY + 10}
				part = PartRegistry.createPart('a', {-3})
			end

			if part and location then
				table.insert(self.world.info.events.create,
							 {"structures", location, part})
			end
			self.menu = nil
		end
	else
		if menuButton == "cancel" then
			if self.selection then
				-- If selection mode is enabled, just leave selection mode.
				self.selection = nil
			else
				-- If selection mode is not enabled, open the menu when the 
				-- cancel key is pressed.
				self.openMenu = true
			end

			return
		elseif not order then
			return
		else
			local cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, 
																self.cursorY)
			if order == "build" or order == "destroy" then
				self.selected:pressed(cursorX, cursorY, order)

			elseif order == "playerMenu" then
				if debugmode then
					
					local x, y, width, height = self.camera:getScissor()
					self.menu = Menu.create(width/2, 100, 5,
											self.menuButtonNames, self.camera)
				end
			elseif order == "zoomIn" then
				self.camera:adjustZoom(1)
			elseif order == "zoomOut" then
				self.camera:adjustZoom(-1)
			end
		end
	end
end

function Player:buttonreleased(source, button)
	local order = Controls.test("released", self.controls, source, button)

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

	self:drawWorldObjects(self.world, self.camera:getWorldBoarder())

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

	if self.menu then
		self.menu:draw()
	end

	self.camera:drawExtras(point, {self.cursorX, self.cursorY})
end

function Player.drawWorldObjects(world, a, b, c, d)
	local callbackData = {}

	function callback(fixture)
		table.insert(callbackData, fixture:getUserData())
		return true
	end

	world.physics:queryBoundingBox(a, b, c, d, callback)

	for drawlayer, object in ipairs(callbackData) do
		object:draw()
	end
end

return Player

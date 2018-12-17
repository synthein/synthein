local Controls = require("controls")
local Selection = require("selection")
local Menu = require("menu")
local PartRegistry = require("world/shipparts/partRegistry")
local LocationTable = require("locationTable")

local Player = {}
Player.__index = Player

function Player.create(world, controls, structure, camera)
	local self = {}
	setmetatable(self, Player)

	self.world = world
	self.controls = controls
	self.ship = structure
	self.camera = camera
	self.drawWorldObjects = self.camera.wrap(Player.drawWorldObjects, true)
	self.drawExtras = self.camera.wrap(Player.drawExtras, false)

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
	self.debugmode = false

	self.compass = love.graphics.newImage("res/images/compass.png")
	self.cursor = love.graphics.newImage("res/images/pointer.png")

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
	if button == "f12" then self.debugmode = not self.debugmode end

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
			local buttonAction = self.menuButtonNames[buttonInt]

			local cameraX, cameraY = self.camera:getPosition()
			local part, location
			if buttonAction == "Block" then
				-- Spawn a block
				location = {cameraX, cameraY + 5}
				part = PartRegistry.createPart('b')
			elseif buttonAction == "Engine" then
				-- Spawn an engine
				location = {cameraX + 5, cameraY + 5}
				part = PartRegistry.createPart('e')
			elseif buttonAction == "Gun" then
				-- Spawn a gun
				location = {cameraX - 5, cameraY + 5}
				part = PartRegistry.createPart('g')
			elseif buttonAction == "AI" then
				--Spawn an AI
				location = {cameraX - 10, cameraY + 10}
				part = PartRegistry.createPart('a', {self.ship:getTeam()})
			elseif buttonAction == "Enemy" then
				--Spawn an Enemy
				location = {cameraX + 10, cameraY + 10}
				part = PartRegistry.createPart('a', {-3})
			end

			if part and location then
				-- TODO: Move this pattern to a function and write a unit test
				-- for it.
				location = LocationTable(unpack(location))
				table.insert(self.world.info.events.create,
							 {"structure", location, part})
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
				if self.debugmode then
					self.menu = Menu.create(
						100,
						5,
						self.menuButtonNames,
						self.camera
					)
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

	local cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
	if order == "build" then
		self.selected:released(cursorX, cursorY)
	end
end

function Player:draw()
	if self.ship then
		self.camera:setX(self.ship.body:getX())
		self.camera:setY(self.ship.body:getY())
	end

	self:drawWorldObjects()
	self:drawExtras()
end

function Player:drawWorldObjects()
	local a, b, c, d = self.camera:getWorldBorder()
	local callbackData = {}

	local function callback(fixture)
		table.insert(callbackData, fixture:getUserData())
		return true
	end

	self.world.physics:queryBoundingBox(a, b, c, d, callback)

	for _, object in ipairs(callbackData) do
		object:draw()
	end
end

function Player:drawExtras()
	local cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
	if self.selected then
		self.selected:draw(cursorX, cursorY)
	end

	if self.menu then
		self.menu:draw()
	end

	local cameraX, cameraY = self.camera:getPosition()
	local _, _, screenWidth, screenHeight = self.camera:getScissor()

	local point = {0,0}
	if self.ship then
		local leader = (self.ship.corePart or {}).leader
		if leader then
			point = leader:getLocation()
		end
		if self.ship.isDestroyed then
			self.ship = nil
		end
	else
		local previousFont = love.graphics.getFont()
		local font = love.graphics.newFont(20)
		love.graphics.setFont(font)
		love.graphics.print("Game Over", 10, screenHeight - 30, 0, 1, 1, 0, 0, 0, 0)
		love.graphics.setFont(previousFont)
	end

	-- Draw the compass in the lower right hand coner 60 pixels from the edges.
	love.graphics.draw(
			self.compass,
			screenWidth - 60,
			screenHeight - 60,
			math.atan2(cameraX - point[1], cameraY - point[2]) + math.pi,
			1, 1, 25, 25)
	love.graphics.draw(self.cursor, self.cursorX - 2, self.cursorY - 2)

	-- Draw a box around the entire region.
	love.graphics.rectangle(
		"line",
		0,
		0,
		screenWidth,
		screenHeight
	)
end

return Player

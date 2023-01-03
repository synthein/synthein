local Controls = require("controls")
local Selection = require("selection")
local PartSelector = require("partSelector")
local PartRegistry = require("world/shipparts/partRegistry")
local LocationTable = require("locationTable")
local PhysicsReferences = require("world/physicsReferences")
local Settings = require("settings")

local lume = require("vendor/lume")

local Player = {}
Player.__index = Player

function Player.create(world, controls, structure, camera)
	local self = {}
	setmetatable(self, Player)

	self.world = world
	self.controls = controls
	self.ship = structure
	self.camera = camera

	if self.ship then
		self.camera.body = structure.body
		self.selected = Selection.create(world, self.ship.corePart:getTeam(), self.camera)
	end

	self.menu = nil
	self.menuOpen = false
	self.closeMenu = false
	self.openMenu = false
	self.partSelector = PartSelector.create(250, 5, {"Test"})

	self.selection = nil
	self.cancelKeyDown = false
	self.selectionKeyDown = false
	self.isBuilding = false
	self.isRemoving = false
	self.isCameraAngleFixed = true
	self.partX = nil
	self.partY = nil
	self.cursorX = 0
	self.cursorY = 0

	self.cursor = love.graphics.newImage("res/images/pointer.png")

	self.showHealth = false

	return self
end

function Player:handleInput()
	-----------------------
	----- Set Cursor  -----
	-----------------------
	self.cursorX = Controls.setCursor(self.controls.cursorX, self.cursorX)
	self.cursorY = Controls.setCursor(self.controls.cursorY, self.cursorY)
	self.cursorX, self.cursorY = self.camera:limitCursor(
		self.cursorX,
		self.cursorY)
	self.partSelector:mousemoved(self.cursorX, self.cursorY)

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

function Player:buttonpressed(source, button, debugmode)
	if button == "h" then self.showHealth = not self.showHealth end
	if button == "f5" then self.isCameraAngleFixed = not self.isCameraAngleFixed end

	local menuButton = Controls.test("menu", self.controls, source, button)
	local order = Controls.test("pressed", self.controls, source, button)

	if self.menu then

		if not menuButton then
			return
		end

		if menuButton == "cancel" or menuButton == "playerMenu" then
			-- Exit menu if canel is pressed.
			self.menu = nil
		elseif menuButton == "confirm" then
			local part = self.partSelector:keypressed("return")
			if part then
				local camera = self.camera
				self.world.info.create(
					"structure",
					LocationTable(unpack({camera.x, camera.y + 5})),
					PartRegistry.createPart(part))
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
					self.menu = true
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

function Player:draw(debugmode)
	self.camera:drawPlayer(self, debugmode)
end

return Player

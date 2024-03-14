local Selection = require("selection")
local PartSelector = require("widgets/partSelector")
local PartRegistry = require("world/shipparts/partRegistry")

local Player = {}
Player.__index = Player

function Player.create(world, controls, ship, camera)
	local self = {}
	setmetatable(self, Player)

	self.world = world
	self.controls = controls
	self.ship = ship
	self.camera = camera


	if ship then
		self.camera.body = ship.body
		self.selected = Selection.create(world, self.ship.corePart:getTeam())

		local corePart = ship.corePart
		if corePart then
			self.camera.hud:setCommand(corePart:getCommand())
		end
	end

	self.menu = nil
	self.menuOpen = false
	self.closeMenu = false
	self.openMenu = false
	self.partSelector = PartSelector.create(250)

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
	local controls = self.controls

	-- Set Cursor Position
	local cursorX, cursorY = self.cursorX, self.cursorY

	cursorX, cursorY = controls:getCursorPosition(cursorX, cursorY)
	cursorX, cursorY = self.camera:limitCursor(cursorX, cursorY)
	self.partSelector:mousemoved({x = cursorX, y = cursorY})

	self.cursorX, self.cursorY = cursorX, cursorY

	-- Pass Commands To Ship
	local ship = self.ship
	if ship then
		local corePart = ship.corePart
		if corePart then
			corePart:setOrders(controls:getOrders())
		else
			self.ship = nil
		end
	end
end

function Player:pressed(control)
	if self.menu then
		
	else
		
	end
end

function Player:buttonpressed(source, button, debugmode)
	if button == "h" then self.showHealth = not self.showHealth end
	if button == "f5" then self.isCameraAngleFixed = not self.isCameraAngleFixed end

	local menuButton = self.controls:test("menu", source, button)
	local order = self.controls:test("pressed", source, button)

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
					{camera.x, camera.y + 5},
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
			self.camera.hud:keypressed(button)
		else
			self.camera.hud:pressed(order)
			if order == "build" or order == "destroy" then
				local cursorX, cursorY = self.camera:getWorldCoords(
					self.cursorX,
					self.cursorY)
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
	local order = self.controls:test("released", source, button)

	local cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
	if order == "build" then
		self.selected:released(cursorX, cursorY)
	end
end

function Player:draw(debugmode)
	if self.ship then
		if self.selected:isBuildingOnStructure() then
			self.camera.body = self.selected.structure.body
		else
			self.camera.body = self.ship.body
		end
	end

	self.camera:drawPlayer(self, debugmode)
end

return Player

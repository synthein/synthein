local PartSelector = require("widgets/partSelector")
local PartRegistry = require("world/shipparts/partRegistry")

local Player = {}
Player.__index = Player

function Player.create(world, controls, ship, viewPort)
	local self = {}
	setmetatable(self, Player)

	self.world = world
	self.controls = controls
	self.ship = ship
	self.viewPort = viewPort
	self.camera = viewPort.camera


	if ship then
		self.camera.body = ship.body

		-- TODO: move to hud
		-- self.selection:whenBuildingOnStructure(function()
		-- 	self.camera:setTarget(self.selection.structure.body)
		-- end)

		-- self.selection:whenDoneBuildingOnStructure(function()
		-- 	self.camera:setTarget(self.ship.body)
		-- end)

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

	self.isBuilding = false
	self.isRemoving = false
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

function Player:cursorpressed(cursor, control, debugmodeEnabled)
	if self.menu then
		if control.menu == "cancel" then
			self.menu = nil
		end

	else
		if control.ship == "health" then
			self.showHealth = not self.showHealth
		elseif control.ship == "cameraRotate" then
			self.camera.angleFixed = not self.camera.angleFixed
		end

		local cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
		self.camera.hud:cursorpressed({x = cursorX, y = cursorY}, control)
	end
end

function Player:cursorreleased(cursor, control, debugmodeEnabled)
	if self.menu then
	else
		local cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
		self.camera.hud:cursorreleased({x = cursorX, y = cursorY}, control)
	end
end

function Player:pressed(control, debugmodeEnabled)
	if self.menu then
		if control.menu == "cancel" or  control.ship == "playerMenu" then
			self.menu = nil
		elseif control.menu == "confirm" then
			local part = self.partSelector:pressed(control)
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
		if control.ship then
			if control.ship == "playerMenu" then
				if debugmodeEnabled then
					self.menu = true
				end
			elseif control.ship == "health" then
				self.showHealth = not self.showHealth
			elseif control.ship == "cameraRotate" then
				self.camera.angleFixed = not self.camera.angleFixed
			end
		elseif control.menu then
			self.camera.hud:pressed(control)
		end
	end
end

function Player:buttonpressed(source, button, debugmode)

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
		local cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
		self.camera.hud:cursorpressed({cursorX, cursorY}, order)

		if menuButton == "cancel" then
				self.openMenu = true
		elseif not order then
			self.camera.hud:keypressed(button)
		else
			self.camera.hud:pressed(order)

			if order == "playerMenu" then
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

	self.camera.hud:cursorreleased({cursorX, cursorY}, order)
end

function Player:update(dt)
	self.camera:update(self, dt)
end

function Player:draw(debugmode)
	self.camera:drawPlayer(self, debugmode)
end

return Player

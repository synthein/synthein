local Util = require("util")
local Controls = require("controls")
local World = require("world")
local Screen = require("screen")
local Selection = require("selection")

local Player = {}
Player.__index = Player

Player.physics = nil

Player.anchors = {}

function Player.setPhysics(setphysics)
	Player.physics = setphysics
end

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

function Player:handleInput()

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
	local order = Controls.testPressed(self.controls, source, button)

	cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
	if order == "build" then
		self.selected:pressed(cursorX, cursorY)
	end
	if order == "destroy" then
		if self.build then
			self.build = nil
		else
			local team
			if self.ship and self.ship.corePart then
				team = self.ship.corePart:getTeam()
			end
			local structure, part, partSide= world:getObject(cursorX, cursorY, "structures")
			--local partIndex
			--if partInfo then
			--	partIndex = partInfo[1]
			--end
			
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
	if order == "zoomIn" then
		self.camera:adjustZoom(1)
	end
	if order == "zoomOut" then
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

	Player.callbackData.objects = {}
	local a, b, c, d = self.camera:getWorldBoarder()
	self.world.physics:queryBoundingBox(a, b, c, d, Player.fixtureCallback)

	for drawlayer, object in ipairs(Player.callbackData.objects) do
		object:draw(self.camera)
	end

	cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)
	if self.selected then
		self.selected:draw(cursorX, cursorY)
	end

	local point
	if self.ship and not self.ship.isDetroyed and self.ship.corePart then
		point = {Player.anchors[self.ship.corePart:getTeam()]:getLocation()}
	else
		point = {0,1}
	end
	self.camera:drawExtras(point)
end

Player.callbackData = {objects = {}}

function Player.fixtureCallback(fixture)
	table.insert(Player.callbackData.objects, fixture:getUserData())
	return true
end

return Player

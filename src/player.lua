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
	self.drawWorldObjects = self.camera.wrap(Player.drawWorldObjects, true)
	self.drawHUD = self.camera.wrap(Player.drawHUD, false)

	if self.ship then
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
				local cameraX, cameraY = self.camera:getPosition()
				self.world.info.create(
					"structure",
					LocationTable(unpack({cameraX, cameraY + 5})),
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
	if self.ship then
		self.camera:setX(self.ship.body:getX())
		self.camera:setY(self.ship.body:getY())
		self.camera:setAngle(self.isCameraAngleFixed and 0 or self.ship.body:getAngle())
	end

	self:drawWorldObjects(debugmode)
	self:drawHUD()
end

local function debugDraw(fixture)
	love.graphics.push("all")
	love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
	love.graphics.setLineWidth(2/Settings.PARTSIZE)

	local shape = fixture:getShape()
	local type = shape:getType()

	if type == "circle" then
		local x, y = shape:getPoint()
		x, y = fixture:getBody():getWorldPoint(x, y)
		love.graphics.circle("line", x, y, shape:getRadius())
	elseif type == "polygon" then
		love.graphics.polygon("line", fixture:getBody():getWorldPoints(shape:getPoints()))
	else
		error("Unhandled shape type \"" .. type .. "\"")
	end

	love.graphics.pop()
end

function Player:drawWorldObjects(debugmode)
	local drawOrder = {
		"visual",
		"projectiles",
		"missile",
		"general",
		"shield"
	}
	if debugmode then
		table.insert(drawOrder, "sensor")
	end

	local fixtureList = {}

	for _, c in ipairs(drawOrder) do
		fixtureList[PhysicsReferences.categories[c]] = {}
	end

	local a, b, c, d = self.camera:getWorldBorder()

	local function callback(fixture)
		local category = fixture:getFilterData()
		if fixtureList[category] then
			table.insert(fixtureList[category], fixture)
		end
		return true
	end

	self.world.physics:queryBoundingBox(a, b, c, d, callback)

	for _, category in ipairs(drawOrder) do
		local categoryNumber = PhysicsReferences.categories[category]
		for _, fixture in ipairs(fixtureList[categoryNumber]) do
			local object = fixture:getUserData()
			if object.draw then object:draw(fixture, self.showHealth) end
			if debugmode then
				debugDraw(fixture)
			end
		end
	end


	local shieldCategoryNumber = PhysicsReferences.categories["shield"]

	local testPointFunctions = {}
	for _, shieldFixture in ipairs(fixtureList[shieldCategoryNumber]) do
		table.insert(testPointFunctions, shieldFixture:getUserData().testPoint())
	end
	self.shieldPoints = self.camera:testPoints(testPointFunctions)

	if self.selected then
		self.selected:draw(
			self.camera:getWorldCoords(
				self.cursorX,
				self.cursorY))
	end
end

function drawCompass(width, height, angle)
	-- Draw the compass in the lower right hand corner.
	local compassSize = 20
	local compassPadding = 10
	local compassX = width - compassSize - compassPadding
	local compassY = height - compassSize - compassPadding

	love.graphics.circle(
		"line",
		compassX,
		compassY,
		compassSize
	)
	local needleX, needleY = lume.vector(
		angle,
		compassSize
	)
	love.graphics.polygon(
		"fill",
		compassX - needleX * 0.1,
		compassY - needleY * 0.1,
		compassX + needleY * 0.1,
		compassY - needleX * 0.1,
		compassX + needleX,
		compassY + needleY,
		compassX - needleY * 0.1,
		compassY + needleX * 0.1
	)
end

function Player:drawHUD()
	love.graphics.setColor(31/255, 63/255, 143/255, 95/255)
	local drawPoints = love.graphics.points
	for _, list in ipairs(self.shieldPoints) do
		drawPoints(unpack(list))
	end
	love.graphics.setColor(1, 1, 1, 1)

	local cursorX, cursorY = self.camera:getWorldCoords(self.cursorX, self.cursorY)

	if self.menu then
		self.partSelector:draw()
	end

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

	local x, y, angle = self.camera:getPosition()
	local _, _, width, height = self.camera:getScissor()
	local compassAngle = math.atan2(x - point[1], y - point[2]) + math.pi/2 + (self.isCameraAngleFixed and 0 or angle)

	drawCompass(width, height, compassAngle)

	-- Draw the cursor.
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

local PhysicsReferences = require("world/physicsReferences")

local lume = require("vendor/lume")


local Camera = {}
Camera.__index = Camera

function Camera.create()
	local self = {}
	setmetatable(self, Camera)

	self.x = 0
	self.y = 0
	self.angle = 0
	self.zoomInt = 8
	self:adjustZoom(0)
	self.scissorX = 0
	self.scissorY = 0
	self.scissorWidth = 0
	self.scissorHeight = 0

	self.graphics = {}
	setmetatable(self.graphics, self)

	return self
end

function Camera:getPosition()
	return self.x, self.y, self.angle
end

function Camera:setX(newX)
	self.x = newX
end

function Camera:setY(newY)
	self.y = newY
end

function Camera:setAngle(newAngle)
	self.angle = newAngle
end

function Camera:getWorldCoords(cursorX, cursorY)
	local x =  (cursorX - self.scissorWidth/2  - self.scissorX) / self.zoom + self.x
	local y = -(cursorY - self.scissorHeight/2 - self.scissorY) / self.zoom + self.y
	return x, y
end

function Camera:getScreenCoords(worldX, worldY, a, b)
	local x =  self.zoom * (worldX - self.x) + self.scissorX + self.scissorWidth/2
	local y = -self.zoom * (worldY - self.y) + self.scissorY + self.scissorHeight/2
	a = self.zoom * a
	b = self.zoom * b
	return x, y, a, b
end

function Camera:getWorldBorder()
	return self.x - self.scissorWidth /(2 * self.zoom),
		   self.y - self.scissorHeight/(2 * self.zoom),
		   self.x + self.scissorWidth /(2 * self.zoom),
		   self.y + self.scissorHeight/(2 * self.zoom)
end

-- Make sure the correct transforms are active
function Camera:getAllPoints()
	local pointTable = {}
	local table_insert = table.insert
	local inverseTransform = love.graphics.inverseTransformPoint
	local xdx, xdy, ydx, ydy
	local p00x, p00y = inverseTransform(0, 0)
	local p10x, p10y = inverseTransform(1, 0)
	local p01x, p01y = inverseTransform(0, 1)
	xdx = p10x - p00x
	xdy = p10y - p00y
	ydx = p01x - p00x
	ydy = p01y - p00y
	local ye = self.scissorHeight - 1
	local xe = self.scissorWidth - 1
	for y = 0, ye do
		local row = {}
		for x = 0, xe do
			row[x+1] = {p00x + x * xdx + y * ydx, p00y + x * xdy + y * ydy}
		end
		pointTable[y+1] = row
	end

	return pointTable
end

-- Make sure the correct transforms are active
function Camera:testPoints(testFunctions)
	local table_insert = table.insert
	local inverseTransform = love.graphics.inverseTransformPoint
	local xdx, xdy, ydx, ydy
	local p00x, p00y = inverseTransform(0, 0)
	local p10x, p10y = inverseTransform(1, 0)
	local p01x, p01y = inverseTransform(0, 1)
	xdx = p10x - p00x
	xdy = p10y - p00y
	ydx = p01x - p00x
	ydy = p01y - p00y
	local ye = self.scissorHeight - 1
	local xe = self.scissorWidth - 1
	local drawPoints = {}
	local pointList = {}
	local l = 1
	for y = 0, ye do
		local row = {}
		for x = 0, xe do
			local result
			for _, test in ipairs(testFunctions) do
				result = result or test(
					p00x + x * xdx + y * ydx, p00y + x * xdy + y * ydy)
			end

			if result then
				pointList[l] = x
				pointList[l+1] = y
				l = l + 2
				if l >= 250 then
					table.insert(drawPoints, pointList)
					pointList = {}
					l = 1
				end
			end
		end
	end

	return drawPoints
end

function Camera:adjustZoom(step)

	self.zoomInt = self.zoomInt + step

	local remainder = self.zoomInt%6
	local exponential = (self.zoomInt - remainder)/6

	self.zoom = 10 ^ exponential

	if remainder == 1 then
		self.zoom = self.zoom * 1.5 --10 ^ (1 / 6) = 1.47
	elseif remainder == 2 then
		self.zoom = self.zoom * 2   --10 ^ (2 / 6) = 2.15
	elseif remainder == 3 then
		self.zoom = self.zoom * 3   --10 ^ (3 / 6) = 3.16
	elseif remainder == 4 then
		self.zoom = self.zoom * 5   --10 ^ (4 / 6) = 4.64
	elseif remainder == 5 then
		self.zoom = self.zoom * 7   --10 ^ (5 / 6) = 6.81
	end
end

function Camera:setScissor(x, y, width, height)
	self.scissorX = x
	self.scissorY = y
	self.scissorWidth = width
	self.scissorHeight = height
end

function Camera:getScissor()
	return self.scissorX, self.scissorY, self.scissorWidth, self.scissorHeight
end

function Camera:limitCursor(cursorX, cursorY)
	if cursorX < self.scissorX then
		cursorX = self.scissorX
	elseif cursorX > self.scissorX + self.scissorWidth then
		cursorX = self.scissorX + self.scissorWidth
	end
	if cursorY < self.scissorY then
		cursorY = self.scissorY
	elseif cursorY > self.scissorY + self.scissorHeight then
		cursorY = self.scissorY + self.scissorHeight
	end
	return cursorX, cursorY
end

function Camera:draw(image, x, y, angle, sx, sy, ox, oy)
	love.graphics.setScissor(self:getScissor())

	x, y, sx, sy = self:getScreenCoords(x, y, sx, sy)
	love.graphics.draw(image, x, y, -angle, sx, sy, ox, oy)

	love.graphics.setScissor()
end

function Camera:enable(inWorld)
	love.graphics.setScissor(self:getScissor())
	love.graphics.translate(self.scissorX, self.scissorY)
	if inWorld then
		love.graphics.translate(self.scissorWidth/2, self.scissorHeight/2)
		love.graphics.rotate(self.angle)
		love.graphics.scale(self.zoom, -self.zoom)
		love.graphics.translate(- self.x, - self.y)
		--x =  self.zoom * (worldX - self.x) + self.scissorX + self.scissorWidth/2
		--y = -self.zoom * (worldY - self.y) + self.scissorY + self.scissorHeight/2
	end
end

function Camera:disable()
	love.graphics.origin()
	love.graphics.setScissor()
end

function Camera:run(f, inWorld)
	self:enable(inWorld)
	f()
	self:disable()
end

function Camera.wrap(f, inWorld)
	return function(self, ...)
		self.camera:enable(inWorld)
		f(self, ...)
		self.camera:disable()
	end
end

function Camera:print(string, x, y)
	x = x or 0
	y = y or 0
	love.graphics.print(string, self.scissorX + x, self.scissorY + y)
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

function Camera:drawWorldObjects(player, debugmode)
	player.camera:enable(true)
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

	local a, b, c, d = player.camera:getWorldBorder()

	local function callback(fixture)
		local category = fixture:getFilterData()
		if fixtureList[category] then
			table.insert(fixtureList[category], fixture)
		end
		return true
	end

	player.world.physics:queryBoundingBox(a, b, c, d, callback)

	for _, category in ipairs(drawOrder) do
		local categoryNumber = PhysicsReferences.categories[category]
		for _, fixture in ipairs(fixtureList[categoryNumber]) do
			local object = fixture:getUserData()
			if object.draw then object:draw(fixture, player.showHealth) end
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
	player.shieldPoints = player.camera:testPoints(testPointFunctions)

	if player.selected then
		player.selected:draw(
			player.camera:getWorldCoords(
				player.cursorX,
				player.cursorY))
	end

	player.camera:disable()
end

local function drawCompass(width, height, angle)
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

function Camera:drawHUD(player)
	player.camera:enable(false)
	love.graphics.setColor(31/255, 63/255, 143/255, 95/255)
	local drawPoints = love.graphics.points
	for _, list in ipairs(player.shieldPoints) do
		drawPoints(unpack(list))
	end
	love.graphics.setColor(1, 1, 1, 1)

	local cursorX, cursorY = player.camera:getWorldCoords(player.cursorX, player.cursorY)

	if player.menu then
		player.partSelector:draw()
	end

	local _, _, screenWidth, screenHeight = player.camera:getScissor()

	local point = {0,0}
	if player.ship then
		local leader = (player.ship.corePart or {}).leader
		if leader then
			point = leader:getLocation()
		end
		if player.ship.isDestroyed then
			player.ship = nil
		end
	else
		local previousFont = love.graphics.getFont()
		local font = love.graphics.newFont(20)
		love.graphics.setFont(font)
		love.graphics.print("Game Over", 10, screenHeight - 30, 0, 1, 1, 0, 0, 0, 0)
		love.graphics.setFont(previousFont)
	end

	local x, y, angle = player.camera:getPosition()
	local _, _, width, height = player.camera:getScissor()
	local compassAngle = math.atan2(x - point[1], y - point[2]) + math.pi/2 + (player.isCameraAngleFixed and 0 or angle)

	drawCompass(width, height, compassAngle)

	-- Draw the cursor.
	love.graphics.draw(player.cursor, player.cursorX - 2, player.cursorY - 2)

	-- Draw a box around the entire region.
	love.graphics.rectangle(
		"line",
		0,
		0,
		screenWidth,
		screenHeight
	)

	player.camera:disable()
end

function Camera:drawPlayer(player, debugmode)
	self:drawWorldObjects(player, debugmode)
	self:drawHUD(player)
end

return Camera

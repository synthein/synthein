local Hud = require("hud")
local PhysicsReferences = require("world/physicsReferences")
local Settings = require("settings")
local lume = require("vendor/lume")
local vector = require("vector")

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
	self.scissor = {x = 0, y = 0, width = 0, height = 0}

	self.graphics = {}
	setmetatable(self.graphics, self)

	self.hud = Hud()
	
	return self
end

function Camera:getWorldCoords(cursorX, cursorY)
	local scissor = self.scissor
	local x =  (cursorX - scissor.width/2  - scissor.x) / self.zoom + self.x
	local y = -(cursorY - scissor.height/2 - scissor.y) / self.zoom + self.y
	return x, y
end

function Camera:getScreenCoords(worldX, worldY, a, b)
	local scissor = self.scissor
	local x =  self.zoom * (worldX - self.x) + scissor.x + scissor.width/2
	local y = -self.zoom * (worldY - self.y) + scissor.y + scissor.height/2
	a = self.zoom * a
	b = self.zoom * b
	return x, y, a, b
end

function Camera:getAABB()
	-- Offset for the corners with the same x and y sign.
	local xoffset1, yoffset1 = vector.rotate(
		self.scissor.width /(2 * self.zoom),
		self.scissor.height/(2 * self.zoom),
		self.angle
	)

	-- Offset for the corners with the opposite x and y sign.
	local xoffset2, yoffset2 = vector.rotate(
		-self.scissor.width/(2 * self.zoom),
		self.scissor.height/(2 * self.zoom),
		self.angle
	)

	local points = {
		{
			self.x - xoffset1,
			self.y - yoffset1
		},
		{
			self.x + xoffset2,
			self.y - yoffset2
		},
		{
			self.x + xoffset1,
			self.y + yoffset1
		},
		{
			self.x - xoffset2,
			self.y + yoffset2
		}
	}

	local minX, maxX = self.x, self.x
	local minY, maxY = self.y, self.y

	for _, point in ipairs(points) do
		minX = math.min(minX, point[1])
		minY = math.min(minY, point[2])
		maxX = math.max(maxX, point[1])
		maxY = math.max(maxY, point[2])
	end

	return minX, minY, maxX, maxY
		
end

-- Make sure the correct transforms are active
function Camera:getAllPoints()
	local scissor = self.scissor
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
	local ye = scissor.height - 1
	local xe = scissor.width - 1
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
	local scissor = self.scissor
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
	local ye = scissor.height - 1
	local xe = scissor.width - 1
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
	self.scissor = {x = x, y = y, width = width, height = height}
end

function Camera:limitCursor(cursorX, cursorY)
	local width = self.scissor.width
	local height = self.scissor.height

	return lume.clamp(cursorX, 0, width), lume.clamp(cursorY, 0, height)
end

function Camera:print(string, x, y)
	x = x or 0
	y = y or 0
	local scissor = self.scissor
	love.graphics.print(string, scissor.x + x, scissor.y + y)
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

	local function callback(fixture)
		local category = fixture:getFilterData()
		if fixtureList[category] then
			table.insert(fixtureList[category], fixture)
		end
		return true
	end

	local a, b, c, d = player.camera:getAABB()
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
end

function Camera:drawPlayer(player, debugmode)
	local compassAngle = 0
	local gameOver = false
	
	--TODO this no longer makes sense
	local body = self.body
	if body then
		if body:isDestroyed() then
			self.body = nil
		else
			self.x, self.y = body:getPosition()
			self.angle = player.isCameraAngleFixed and 0 or body:getAngle()
					
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
				gameOver = true
			end

			compassAngle = math.atan2(self.x - point[1], self.y - point[2])
				+ math.pi/2 + self.angle
		end
	end

	local scissor = self.scissor

	local viewPort = {}
	viewPort.width = scissor.width
	viewPort.height = scissor.height
	
	local playerDrawPack = {}
	playerDrawPack.compassAngle = compassAngle
	playerDrawPack.cursor = {x = player.cursorX, y = player.cursorY, image = player.cursor}
	playerDrawPack.menu = player.menu
	playerDrawPack.partSelector = player.partSelector
	playerDrawPack.gameOver = gameOver
	

	love.graphics.setScissor(unpack(scissor))

	--Set translation for world objects
	love.graphics.translate(scissor.x, scissor.y)
	love.graphics.translate(scissor.width/2, scissor.height/2)
	love.graphics.rotate(self.angle)
	love.graphics.scale(self.zoom, -self.zoom)
	love.graphics.translate(- self.x, - self.y)
	
	self:drawWorldObjects(player, debugmode)

	--Set translation for hud
	love.graphics.origin()
	love.graphics.translate(scissor.x, scissor.y)
	
	--Draw shields
	love.graphics.setColor(31/255, 63/255, 143/255, 95/255)
	local drawPoints = love.graphics.points
	for _, list in ipairs(player.shieldPoints) do
		drawPoints(unpack(list))
	end
	love.graphics.setColor(1, 1, 1, 1)
	
	self.hud:draw(playerDrawPack, viewPort)
	
	--Reset graphics translation
	love.graphics.origin()

	love.graphics.setScissor()
end

return Camera

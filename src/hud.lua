local CanvasUtils = require("widgets/canvasUtils")
local CircleMenu = require("circleMenu")
local ListSelector = require("widgets/listSelector")
local StructureMath = require("world/structureMath")
local vector = require("vector")

local Hud = class()

local halfCursorWidth = 2

function Hud:__create()
	self.formationSelector = ListSelector(
		40,
		0, 0,
		150, 120,
		{})
	self.formationScaleTable = CanvasUtils.generateScaleTable("right", "top", "right", "top")

	self.selectedMenu = "formation"
	return self
end

function Hud:setCommand(commandModule)
	self.command = commandModule
	local formationList = commandModule.availableFormations
	self.formationList = formationList
	self.formationSelector:setList(formationList)
end

function Hud:keypressed(key)
	if self.selectedMenu == "formation" then
		local formationIndex = self.formationSelector:pressed(key)
		print("formationIndex ", formationIndex)
		if formationIndex then
			self.command.activeFormation = self.formationList[formationIndex]
		end
	end
end

function Hud:pressed(order)
	if self.selectedMenu then
		local formationIndex = self.formationSelector:pressed(order)
		if formationIndex and formationIndex ~= 0 then
			self.command.activeFormation = self.formationList[formationIndex]
		end
	end
end

local function drawCompass(viewPort, compassAngle)
	local width = viewPort.width
	local height = viewPort.height

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
	local needleX, needleY = vector.components(
		compassSize,
		compassAngle
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

local function drawSelection(selection, cursor, zoom)
	local structure = selection.structure
	local part = selection.part
	local build = selection.build
	if structure and part then
		local location = part.location
		local partX, partY = unpack(location)
		local body = structure.body
		local angle -- Body angle if building else 0

		local strength, labels
		if build then
			angle = body:getAngle()
			strength = {}
			local x, y = body:getWorldPoints(partX, partY)
			local newAngle = vector.angle(cursor.worldX - x, cursor.worldY - y)
			local partSide = CircleMenu.angleToIndex(newAngle, 4)
			local l = {partX, partY}
			for i = 1,4 do
				l[3] = i
				local _, partB, connection = structure:testEdge(l)
				local connectable = not partB and connection
				local highlight = i == partSide
				local brightness = highlight and 2 or 1
				strength[i] = connectable and brightness or 0
			end
		else
			angle = 0
			local x, y = body:getWorldPoints(partX, partY)
			strength, labels = part:getMenu()
			local newAngle = vector.angle(cursor.worldX - x, cursor.worldY - y)
			local index = CircleMenu.angleToIndex(newAngle, #strength)
			if strength[index] == 1 then
				strength[index] = 2
			end
		end
		if strength then
			local x, y = body:getWorldPoints(partX, partY)
			CircleMenu.draw(x, y, angle, 1, strength, labels)
		end
	end
	if build then

		local body = build.body
		local vec = build.annexeeBaseVector
		if body and vec and build.mode > 2 then
			local l = StructureMath.addDirectionVector(vec, vec[3], .5)
			local x, y = body:getWorldPoint(l[1], l[2])
			local angle = body:getAngle()

			love.graphics.draw(
				cursor.image,
				x, y, angle,
				1/zoom, 1/zoom,
				halfCursorWidth, halfCursorWidth)
		end
	end
	local assign = selection.assign
	if assign then
		local body = assign.modules.hull.fixture:getBody()
		local x, y  = body:getPosition()
		local angle = body:getAngle()

		love.graphics.draw(
			cursor.image,
			x, y, angle,
			1/zoom, 1/zoom,
			halfCursorWidth, halfCursorWidth)
	end
end

function Hud:drawLabels(playerDrawPack)
	if playerDrawPack.selection then
		drawSelection(playerDrawPack.selection, playerDrawPack.cursor, playerDrawPack.zoom)
	end
end

function Hud:draw(playerDrawPack, viewPort)
	if playerDrawPack.menu then
		playerDrawPack.partSelector:draw()
	end

	drawCompass(viewPort, playerDrawPack.compassAngle)

	-- Draw the cursor.
	local cursor = playerDrawPack.cursor
	love.graphics.draw(cursor.image, cursor.x - halfCursorWidth, cursor.y - halfCursorWidth)

	local screenWidth = viewPort.width
	local screenHeight = viewPort.height

	-- Draw a box around the entire region.
	--TODO double check this on two Player
	love.graphics.rectangle(
		"line",
		0, 0,
		screenWidth, screenHeight
	)


	if playerDrawPack.gameOver then
		local previousFont = love.graphics.getFont()
		local font = love.graphics.newFont(20)
		love.graphics.setFont(font)
		love.graphics.print("Game Over", 10, screenHeight - 30, 0, 1, 1, 0, 0, 0, 0)
		love.graphics.setFont(previousFont)
	end

	local canvas = love.graphics.newCanvas(viewPort.width, viewPort.height)

	local within, x, y = CanvasUtils.isWithin(
		cursor.x, cursor.y, 0, 0, self.formationSelector.visableCanvas, canvas, self.formationScaleTable)
	local formationSelectorCanvas = self.formationSelector:draw(viewPort, {x = x, y = y})
	CanvasUtils.copyCanvas(formationSelectorCanvas, 0, 0, self.formationScaleTable, nil, canvas)

	love.graphics.draw(canvas, 0, 0)
end

return Hud

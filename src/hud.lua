local CanvasUtils = require("widgets/canvasUtils")
local CircleMenu = require("circleMenu")
local ListSelector = require("widgets/listSelector")
local Selection = require("selection")
local StructureMath = require("world/structureMath")
local vector = require("syntheinrust").vector

local Hud = class()

local halfCursorWidth = 2

function Hud:__create(world, team)
	self.formationSelector = ListSelector(
		40,
		0, 0,
		150, 120,
		{})
	self.formationScaleTable = CanvasUtils.generateScaleTable("right", "top", "right", "top")
	self.selection = Selection.create(world, team)

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
		if formationIndex then
			self.command.activeFormation = self.formationList[formationIndex]
		end
	end
end

function Hud:cursorpressed(cursor, control)
	-- TODO: pass in the cursor coordinates as screen coordinates, then transform to world coordinates only where needed
	-- TODO: checking for which feature the mouse is over before passing on the function call.
	if self.selectedMenu then
		local formationIndex = self.formationSelector:pressed(control)
		if formationIndex and formationIndex ~= 0 then
			self.command.activeFormation = self.formationList[formationIndex]
		end
	end

	if control.ship == "build" or control.ship == "destroy" then
		-- local cursorX, cursorY = self.camera:getWorldCoords(cursor.x, cursor.y)
		self.selection:cursorpressed(cursor, control)
	end
end

function Hud:cursorreleased(cursor, control)
	-- TODO: pass in the cursor coordinates as screen coordinates, then transform to world coordinates only where needed

	if control.ship == "build" or control.ship == "destroy" then
		-- local cursorX, cursorY = self.camera:getWorldCoords(cursor.x, cursor.y)
		self.selection:cursorreleased(cursor, control)
	end
end

function Hud:pressed(control)
	if self.selectedMenu then
		local formationIndex = self.formationSelector:pressed(control)
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

function Hud:drawLabels(playerDrawPack)
	if self.selection then
		self.selection:draw(playerDrawPack.cursor, playerDrawPack.zoom)
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

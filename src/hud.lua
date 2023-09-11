local CanvasUtils = require("widgets/canvasUtils")
local ListSelector = require("widgets/listSelector")
local vector = require("vector")

local Hud = class()

function Hud:__create()
	self.formationSelector = ListSelector(
		40,
		0, 0,
		150, 120,
		{})
	--self.formationSelector:set_reference_points("right", "top", "right", "top")
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
		local formationIndex = self.formationSelector:keypressed(key)
		if formationIndex then
			self.command.activeFormation = self.formationList[formationIndex]
		end
	end
end

function Hud:pressed(order)
	if self.selectedMenu == "formation" then
		local formationIndex = self.formationSelector:pressed()
		if formationIndex then
			self.command.activeFormation = self.formationList[formationIndex]
		end
	end
end

function Hud:drawCompass(viewPort, compassAngle)
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

function Hud:draw(playerDrawPack, viewPort, compassAngle)
	if playerDrawPack.menu then
		playerDrawPack.partSelector:draw()
	end

	self:drawCompass(viewPort, playerDrawPack.compassAngle)

	-- Draw the cursor.
	local cursor = playerDrawPack.cursor
	love.graphics.draw(cursor.image, cursor.x - 2, cursor.y - 2)

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
	if within then
		self.formationSelector:cursorHighlight(x, y)
	end
	local formationSelectorCanvas = self.formationSelector:draw(viewPort, cursor)
	CanvasUtils.copyCanvas(formationSelectorCanvas, 0, 0, self.formationScaleTable, nil, canvas)
	
	love.graphics.draw(canvas, 0, 0)
end

return Hud

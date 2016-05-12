local Util = require("util")
local World = require("world")

local Building = {}
Building.__index = Building

function Building.create(structureList, ship, anchor)
	local self = {}
	setmetatable(self, Building)

	self.pointerImage = love.graphics.newImage("res/images/pointer.png")
	self.pointerWidth = self.pointerImage:getWidth()
	self.structureList = structureList

	-- What are we selecting?
	-- 1 = the structure to annex
	-- 2 = the part within the annexee
	-- 3 = the side of the part within the annexee
	-- 4 = the structure we are adding to
	-- 5 = the part within the structure
	-- 6 = the side of the part within the structure
	self.mode = 1

	-- Instance variables of Building:
	-- self.annexee, the structure to annex
	-- self.annexeeIndex, the index of the annexee in structureList
	-- self.annexeePart, the part in annexee to connect to
	-- self.annexeePartIndex, the index of the part in annexee
	-- self.orientation, the orientation of the annexee
	-- self.structure, the structure we are adding to
	-- self.structurePart, the part in the structure to connect to
	-- self.structurePartIndex, the index of the part in the structure
	-- self.side, the side to attach the annexee to

		return self
end

function Building:pressed(mouseWorldX, mouseWorldY)
	if self.mode == 1 then

		self.annexee, self.annexeePart
			= world:getWorldStructure(mouseWorldX, mouseWorldY)
		self.mode = 2
		if not self.annexee then
			return true --end build
		else
			return false --don't end build
		end

	elseif self.mode == 3 then
		self.structure, self.structurePart = 
		world:getStructure(mouseWorldX,mouseWorldY)
		self.mode = 4
		if not self.structure then
			return true --end build
		else
			return false --don't end build
		end
	end
end

function Building:released(mouseWorldX, mouseWorldY)
	if self.mode == 2 then
		
		local partX, partY, partAngle = self.annexee:getAbsPartCoords(self.annexee:findPart(self.annexeePart))
		local partSide = Util.vectorAngle(
			mouseWorldX - partX, 
			mouseWorldY - partY) - partAngle 
		local a, b = Util.vectorComponents(Util.vectorMagnitude(mouseWorldX - partX, mouseWorldY - partY), partSide)
		a = Util.absVal(a)
		b = Util.absVal(b)
		self.annexeePartSide = math.floor((partSide*2/math.pi + 3/2) % 4 + 1 )

		if not self.annexeePart.connectableSides[self.annexeePartSide] then
			return true --end build
		end
		if Util.max(a,b) > 10 then
			self.mode = 3
		end
		return false  --don't end build

	elseif self.mode == 4 then
		local partX, partY, partAngle = self.structure:getAbsPartCoords(self.structure:findPart(self.structurePart))
		local partSide = Util.vectorAngle(
			mouseWorldX - partX, 
			mouseWorldY - partY) - partAngle
		local a, b = Util.vectorComponents(Util.vectorMagnitude(mouseWorldX - partX, mouseWorldY - partY), partSide)
		a = Util.absVal(a)
		b = Util.absVal(b)
		self.structurePartSide = math.floor((partSide*2/math.pi + 3/2) % 4 + 1 )
		if Util.max(a,b) < 10 then
			return false  --don't end build
		end
		if self.structure and self.annexee
			and self.structurePart.connectableSides[self.structurePartSide]
			and self.structure ~= self.annexee then
			world:annex(self.annexee, self.annexeePart, self.annexeePartSide, self.annexeeIndex,
						self.structure, self.structurePart, self.structurePartSide)
		end
		self.structure, self.annexee = nil
		return true --end build
	end
end

function Building:draw(globalOffsetX, globalOffsetY, mouseWorldX, mouseWorldY)
	local a, b 
	if self.mode == 2 then
		local partX, partY, partAngle = self.annexee:getAbsPartCoords(self.annexee:findPart(self.annexeePart))
		local partSide = Util.vectorAngle(
			mouseWorldX - partX, 
			mouseWorldY - partY) - partAngle 
		a, b = Util.vectorComponents(Util.vectorMagnitude(mouseWorldX - partX, mouseWorldY - partY), partSide)
		a = Util.absVal(a)
		b = Util.absVal(b)
		if Util.max(a,b) > 10 then
			self.annexeePartSide = math.floor((partSide*2/math.pi + 3/2) % 4 + 1 )
		end
		Building.drawCircle(
			partX, partY, partAngle,
			self.annexeePartSide, self.annexeePart.connectableSides
		)
	elseif self.mode == 4 and self.structure then
		local partX, partY, partAngle = self.structure:getAbsPartCoords(self.structure:findPart(self.structurePart))
		local partSide = Util.vectorAngle(
			mouseWorldX - partX, 
			mouseWorldY - partY) - partAngle
		a, b = Util.vectorComponents(Util.vectorMagnitude(mouseWorldX - partX, mouseWorldY - partY), partSide)
		a = Util.absVal(a)
		b = Util.absVal(b)
		if Util.max(a,b) > 10 then
			self.structurePartSide = math.floor((partSide*2/math.pi + 3/2) % 4 + 1 )
		end
		Building.drawCircle(
			partX, partY, partAngle,
			self.structurePartSide, self.structurePart.connectableSides
		)
	end
	if self.annexeePart and self.annexeePart.connectableSides[self.annexeePartSide] then
		local x, y, partAngle = self.annexee:getAbsPartCoords(self.annexee:findPart(self.annexeePart))
		local offsetX, offsetY -- move the cursor the side that we are selecting
		local angle = (self.annexeePartSide - 2) * math.pi/2 + partAngle
		offsetX, offsetY = Util.vectorComponents(10, angle)
		love.graphics.draw(
			self.pointerImage,
			SCREEN_WIDTH/2 - globalOffsetX + x + offsetX,
			SCREEN_HEIGHT/2 - globalOffsetY + y + offsetY,
			angle, 
			1, 1, self.pointerWidth/2, self.pointerWidth/2
		)
	end
	if self.mode == 4 and self.structurePart.connectableSides[self.structurePartSide] then
		local x, y, partAngle = self.structure:getAbsPartCoords(self.structure:findPart(self.structurePart))
		local offsetX, offsetY -- move the cursor the side that we are selecting
		local angle = (self.structurePartSide - 2) * math.pi/2 + partAngle
		offsetX, offsetY = Util.vectorComponents(10, angle)
		love.graphics.draw(
			self.pointerImage,
			SCREEN_WIDTH/2 - globalOffsetX + x + offsetX,
			SCREEN_HEIGHT/2 - globalOffsetY + y + offsetY,
			angle, 
			1, 1, self.pointerWidth/2, self.pointerWidth/2
		)
	end
end

function Building.drawCircle(centerX, centerY, angle, highlightedSide, connectableSides)
	love.graphics.setLineWidth(10)

	local radius = 35
	local gap = 2

	for i = 1, 4 do
		if connectableSides[i] then
			if i == highlightedSide then
				love.graphics.setColor(68, 112, 186, 192)
			else
				love.graphics.setColor(22, 65, 138, 192)
			end

			--            |                   | offset by 45° | line up with part side 1 |
			beginAngle =  (     i * math.pi/2 )  - math.pi/4  - math.pi
			middleAngle = (     i * math.pi/2 )               - math.pi
			endAngle =    ( (i+1) * math.pi/2 )  - math.pi/4  - math.pi

			-- Push the arcs out to make a gap between them.
			offsetX, offsetY = Util.vectorComponents(gap, middleAngle + angle)

			love.graphics.arc(
				"line", "open",
				centerX + offsetX - globalOffsetX + SCREEN_WIDTH/2,
				centerY + offsetY - globalOffsetY + SCREEN_HEIGHT/2,
				radius, beginAngle + angle, endAngle + angle, 30)
		end
	end

	love.graphics.setColor(255, 255, 255)
end

return Building

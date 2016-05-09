local Util = require("util")
local World = require("world")

local Building = {}
Building.__index = Building

function Building.create(structureList, ship, anchor)
	local self = {}
	setmetatable(self, Building)

	self.image = love.graphics.newImage("res/images/pointer.png")
	self.width = self.image:getWidth()
	self.structureList = structureList
--	self.ship = ship
--	self.anchor = anchor

	-- What are we selecting?
	-- 1 = the structure to annex
	-- 2 = the part within the annexee
	-- 3 = the side of the part within the annexee
	-- 4 = the structure we are adding to
	-- 5 = the part within the structure
	-- 6 = the side of the part within the structure
	self.mode = 1

	-- Instance variables of Selection:
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
	end
	if self.annexeePart and self.annexeePart.connectableSides[self.annexeePartSide] then
		local x, y, partAngle = self.annexee:getAbsPartCoords(self.annexee:findPart(self.annexeePart))
		local offsetX, offsetY -- move the cursor the side that we are selecting
		local angle = (self.annexeePartSide - 2) * math.pi/2 + partAngle
		offsetX, offsetY = Util.vectorComponents(10, angle)
		love.graphics.draw(
			self.image,
			SCREEN_WIDTH/2 - globalOffsetX + x + offsetX,
			SCREEN_HEIGHT/2 - globalOffsetY + y + offsetY,
			angle, 
			1, 1, self.width/2, self.width/2
		)
	end
	if self.mode == 4 and self.structurePart.connectableSides[self.structurePartSide] then
		local x, y, partAngle = self.structure:getAbsPartCoords(self.structure:findPart(self.structurePart))
		local offsetX, offsetY -- move the cursor the side that we are selecting
		local angle = (self.structurePartSide - 2) * math.pi/2 + partAngle
		offsetX, offsetY = Util.vectorComponents(10, angle)
		love.graphics.draw(
			self.image,
			SCREEN_WIDTH/2 - globalOffsetX + x + offsetX,
			SCREEN_HEIGHT/2 - globalOffsetY + y + offsetY,
			angle, 
			1, 1, self.width/2, self.width/2
		)
	end
end

return Building

local Util = require("util")
local World = require("world")
local Screen = require("screen")

local Building = {}
Building.__index = Building

function Building.create(world, camera)
	local self = {}
	setmetatable(self, Building)

	self.pointerImage = love.graphics.newImage("res/images/pointer.png")
	self.pointerWidth = self.pointerImage:getWidth()
	self.world = world
	self.camera = camera

	self.structure = nil
	self.structurePartIndex = nil
	self.structurePartSide = nil
	self.annexee = nil
	self.annexeePartIndex = nil
	self.annexeePartSide = nil
	self.mode = 1

	return self
end

function Building:setAnnexee(structure, part)
	self.annexee = structure
	self.annexeePart = part
	self.mode = 2
end

function Building:setStructure(structure, part)
	if self.annexee == structure then
		return true
	end
	self.structure = structure
	self.structurePart = part
	self.mode = 4
	return false
end

function Building:setSide(partSide)
	if self.mode == 2 then
		if self.annexeePart.connectableSides[partSide] then
			self.annexeePartSide = partSide
			self.mode = 3
			return false
		else
			return true
		end
	elseif self.mode == 4 then 
		if self.structurePart.connectableSides[partSide] then
			self.structurePartSide = partSide 
			if self.annexee and self.annexeePart and self.annexeePartSide
				and self.structure and self.structurePart
				and self.structurePartSide then
				self.structure:annex(self.annexee, self.annexeePart,
							self.annexeePartSide,
							self.structurePart, self.structurePartSide)
			end
		end
		return true
	end
end

function Building.getStrengthTable(part, partSide)
	connectableSides = part.connectableSides
	strength = {}
	for i = 1, 4 do
		if connectableSides[i] then
			if i == partSide then
				table.insert(strength, 2)
			else
				table.insert(strength, 1)
			end
		else
			table.insert(strength, 0)
		end
	end
	strengthX = strength[2]
	strength[2] = strength[4]
	strength[4] = strengthX
	return strength
end

function Building:draw()
	if self.annexeePart and self.annexeePartSide then
		local x, y, partAngle = self.annexeePart:getWorldLocation()
		local angle = self.annexeePartSide * math.pi/2 + partAngle
		local offsetX, offsetY = Util.vectorComponents(.5, angle)
		self.camera:draw(self.pointerImage,
						 x + offsetX,
						 y + offsetY,
						 angle, 
						 1/20, 1/20, self.pointerWidth/2, self.pointerWidth/2)
	end
end

























--function Building:pressed(mouseWorldX, mouseWorldY)
--	if self.mode == 1 then
--
--	elseif self.mode == 3 then
--		self.structure, self.structurePart = 
--		self.world:getStructure(mouseWorldX,mouseWorldY)
--		self.mode = 4
--		if not self.structure or (self.structure.corePart and self.structure.corePart:getTeam() ~= self.team) then
--			return true --end build
--		else
--			return false --don't end build
--		end
--	end
--end
--
--function Building:released(cursorX, cursorY)
--	local withinPart = true
--	if self.mode == 2 then
--		withinPart, self.annexeePartSide = 
--			self.annexee:withinPart(self.annexee:findPart(self.annexeePart), cursorX, cursorY)
--		if not self.annexeePart.connectableSides[self.annexeePartSide] then
--			return true --end build
--		end
--		if not withinPart then
--			self.mode = 3
--		end
--		return false  --don't end build
--
--	elseif self.mode == 4 then
--		withinPart, self.structurePartSide = 
--			self.structure:withinPart(self.structure:findPart(self.structurePart), cursorX, cursorY)
--		if withinPart then
--			return false  --don't end build
--		end
--		if self.structure and self.annexee
--			and self.structurePart.connectableSides[self.structurePartSide]
--			and self.structure ~= self.annexee then
--			world:annex(self.annexee, self.annexeePart, self.annexeePartSide, self.annexeeIndex,
--						self.structure, self.structurePart, self.structurePartSide)
--		end
--		self.structure, self.annexee = nil
--		return true --end build
--	end
--end
--
--function Building:draw(mouseWorldX, mouseWorldY)
--	local withinPart
--	if self.mode == 2 then
--		local partX, partY, partAngle = self.annexee:getAbsPartCoords(self.annexee:findPart(self.annexeePart))
--		withinPart, self.annexeePartSide = 
--			self.annexee:withinPart(self.annexee:findPart(self.annexeePart), cursorX, cursorY)
--		if withinPart then
--			self.annexeePartSide = nil
--		end
--		self:drawCircle(
--			partX, partY, partAngle,
--			self.annexeePartSide, self.annexeePart.connectableSides
--		)
--	elseif self.mode == 4 and self.structure then
--		local partX, partY, partAngle = self.structure:getAbsPartCoords(self.structure:findPart(self.structurePart))
--		withinPart, self.structurePartSide = 
--			self.structure:withinPart(self.structure:findPart(self.structurePart), cursorX, cursorY)
--		if withinPart then
--			self.structurePartSide = nil
--		end
--		self:drawCircle(
--			partX, partY, partAngle,
--			self.structurePartSide, self.structurePart.connectableSides
--		)
--	end
--	if self.annexeePart and self.annexeePart.connectableSides[self.annexeePartSide] then
--		local x, y, partAngle = self.annexee:getAbsPartCoords(self.annexee:findPart(self.annexeePart))
--		local offsetX, offsetY -- move the cursor the side that we are selecting
--		local angle = self.annexeePartSide * math.pi/2 + partAngle
--		offsetX, offsetY = Util.vectorComponents(10, angle)
--		self.camera:draw(
--						 self.pointerImage,
--						 x + offsetX,
--						 y + offsetY,
--						 angle, 
--						 1, 1, self.pointerWidth/2, self.pointerWidth/2
--		)
--	end
--	if self.mode == 4 and self.structurePart.connectableSides[self.structurePartSide] then
--		local x, y, partAngle = self.structure:getAbsPartCoords(self.structure:findPart(self.structurePart))
--		local offsetX, offsetY -- move the cursor the side that we are selecting
--		local angle = self.structurePartSide * math.pi/2 + partAngle
--		offsetX, offsetY = Util.vectorComponents(10, angle)
--		self.camera:draw(
--			self.pointerImage,
--			x + offsetX,
--			y + offsetY,
--			angle, 
--			1, 1, self.pointerWidth/2, self.pointerWidth/2
--		)
--	end
--end
--
--function Building:drawCircle(centerX, centerY, angle, highlightedSide, connectableSides)
--	strength = {}
--	for i = 1, 4 do
--		if connectableSides[i] then
--			if i == highlightedSide then
--				table.insert(strength, 2)
--			else
--				table.insert(strength, 1)
--			end
--		else
--			table.insert(strength, 0)
--		end
--	end
--	strengthX = strength[2]
--	strength[2] = strength[4]
--	strength[4] = strengthX
--	self.camera:drawCircleMenu(centerX, centerY, angle, 10, strength)
--
--	love.graphics.setColor(255, 255, 255)
--end

return Building

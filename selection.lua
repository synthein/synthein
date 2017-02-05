local Building = require("building")
local Util = require("util")

local Selection = {}
Selection.__index = Selection

function Selection.create(world, team, camera)
	local self = {}
	setmetatable(self, Selection)

	self.world = world
	self.team = team
	self.camera = camera
	self.build = nil
	self.sturcture = nil
	self.partIndex = nil

	return self
end

function Selection:pressed(cursorX, cursorY)
	local structure, partInfo = world:getObject(cursorX, cursorY, "structures")
	local partIndex 
	if partInfo then
		partIndex = partInfo[1]
	end
	if structure and partIndex then
		if self.build then
			if self.build.mode == 3 then
				if not structure.corePart or 
						structure.corePart:getTeam() == self.team then
					self.structure = structure
					self.partIndex = partIndex
					if self.build:setStructure(structure, partIndex) then
						self.structure = nil
						self.partIndex = nil
						self.build = nil
					end
				end
			end
		else
			if structure.corePart then
				local corePart = structure.corePart
				if corePart == structure.parts[partIndex] then
					if corePart:getTeam() == self.team and corePart.ai then
						self.structure = structure
						self.partIndex = partIndex
					end
				end
			else
				self.build = Building.create(self.world, self.camera)
				self.build:setAnnexee(structure, partIndex)
				self.structure = structure
				self.partIndex = partIndex
			end
		end
	end
end

function Selection:released(cursorX, cursorY)
	if self.structure and self.partIndex then
		local withinPart, partSide = 
				self.structure:withinPart(self.partIndex, cursorX, cursorY)
		local x, y, angle = self.structure:getAbsPartCoords(self.partIndex)
		if not withinPart then
			if self.build then
				if self.build:setSide(partSide) then
					self.build = nil
				end
			else
				local strength = self.structure.parts[self.partIndex]:getMenu()
				local newAngle = Util.vectorAngle(cursorX - x, cursorY - y)
				local index = self:angleToIndex(newAngle, #strength)
				self.structure.parts[self.partIndex]:runMenu(index)
			end
			self.structure = nil
			self.partSide = nil
		else
			if not self.build then
				self.structure = nil
				self.partSide = nil
			end
		end
	end
end

function Selection:angleToIndex(angle, length)
	local index = math.floor(((-angle/math.pi + 0.5) * length + 1)/2 % length + 1)
	return index
end

function Selection:draw(cursorX, cursorY)
	if self.structure and self.partIndex then
		local withinPart, partSide =
				self.structure:withinPart(self.partIndex, cursorX, cursorY)
		local x, y, angle = self.structure:getAbsPartCoords(self.partIndex)
		local strength = nil
		if self.build then
			strength = Building.getStrengthTable(self.structure, 
													   self.partIndex,
													   partSide)
		else
			angle = 0
			strength = self.structure.parts[self.partIndex]:getMenu()
			local newAngle = Util.vectorAngle(cursorX - x, cursorY - y)
			local index = self:angleToIndex(newAngle, #strength)
			if strength[index] == 1 then
				strength[index] = 2
			end
		end
		if strength then
			self.camera:drawCircleMenu(x, y, angle, 10, strength)
		end
	end
	if self.build then
		self.build:draw()
	end
end

return Selection

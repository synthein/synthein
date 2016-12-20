local Building = require("building")

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
	local structure, partIndex = world:getStructure(cursorX, cursorY)
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
			self.structure = nil
			self.partSide = nil
			if self.build then
				if self.build:setSide(partSide) then
					self.build = nil
				end
			else
				--run selected task
			end
		end
	end
end

function Selection:draw(cursorX, cursorY)
	if self.structure and self.partIndex then
		local withinPart, partSide =
				self.structure:withinPart(self.partIndex, cursorX, cursorY)
		local x, y, angle = self.structure:getAbsPartCoords(self.partIndex)
		if self.build then
			local strength = Building.getStrengthTable(self.structure, 
													   self.partIndex,
													   partSide)
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

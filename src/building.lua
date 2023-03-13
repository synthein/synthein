local Building = {}
Building.__index = Building
function Building.create()
	local self = {}
	setmetatable(self, Building)

	self.structure = nil
	self.structurePartIndex = nil
	self.annexee = nil
	self.annexeePartIndex = nil
	self.mode = 1

	return self
end

function Building:setAnnexee(structure, part)
	self.annexee = structure
	self.annexeePart = part
	self.mode = 2

	self.annexeeBaseVector = {unpack(part.location)}
	self.body = self.annexeePart.modules["hull"].fixture:getBody()
end

function Building:setStructure(structure, part)
	if self.annexee == structure then
		return true
	end
	self.structure = structure
	self.structurePart = part
	self.mode = 4

	self.structureVector = {unpack(part.location)}

	return false
end

function Building:setSide(partSide)
	if self.mode == 2 then
		self.annexeeBaseVector[3] = partSide
		self.mode = 3
	elseif self.mode == 4 then
		self.structureVector[3] = partSide
		if self.annexee and self.annexeeBaseVector and
			self.structure and self.structureVector then
			self.structure:annex(
				self.annexee,
				self.annexeeBaseVector,
				self.structureVector)
		end
		self.mode = 5
	end
end

return Building

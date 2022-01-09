local StructureMath = require("world/structureMath")

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
	self.annexee = nil
	self.annexeePartIndex = nil
	self.mode = 1

	return self
end

function Building:setAnnexee(structure, part)
	self.annexee = structure
	self.annexeePart = part
	self.mode = 2

	local annexeeX = part.location[1]
	local annexeeY = part.location[2]
	local annexeeSide = part.location[3]

	self.annexeeBaseVector = {annexeeX, annexeeY, annexeeSide}
	self.body = self.annexeePart.modules["hull"].fixture:getBody()
end

function Building:setStructure(structure, part)
	if self.annexee == structure then
		return true
	end
	self.structure = structure
	self.structurePart = part
	self.mode = 4

	local structureOffsetX = part.location[1]
	local structureOffsetY = part.location[2]
	local structureSide = part.location[3]

	self.structureVector = {structureOffsetX, structureOffsetY, structureSide}

	return false
end

function Building:setSide(partSide)
	if self.mode == 2 then
		if self.annexeePart.connectableSides[partSide] then
			self.annexeePartSide = partSide
			self.annexeeBaseVector[3] =
				StructureMath.toDirection(partSide + self.annexeeBaseVector[3])

			self.mode = 3
			return false
		else
			return true
		end
	elseif self.mode == 4 then
		if self.structurePart.connectableSides[partSide] then
			self.structureVector[3] =
				StructureMath.toDirection(partSide + self.structureVector[3])
			if self.annexee and self.annexeeBaseVector and
				self.structure and self.structureVector then
				self.structure:annex(
					self.annexee,
					self.annexeeBaseVector,
					self.structureVector)
			end
		end
		return true
	end
end

function Building:draw()
	local body = self.body
	local vec = self.annexeeBaseVector
	if body and vec and self.mode > 2 then
		local l = StructureMath.addDirectionVector(vec, vec[3], .5)
		local x, y = body:getWorldPoint(l[1], l[2])
		local angle = body:getAngle()

		self.camera:draw(
			self.pointerImage,
			x, y, angle,
			1/20, 1/20,
			self.pointerWidth/2, self.pointerWidth/2)
	end
end

return Building

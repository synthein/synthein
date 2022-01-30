local StructureMath = require("world/structureMath")

local Building = {}
Building.__index = Building
local pointerImage = love.graphics.newImage("res/images/pointer.png")
local pointerWidth = pointerImage:getWidth()
local pointerWidth = pointerImage:getWidth()

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
		self.annexeeBaseVector[3] =
			StructureMath.toDirection(partSide + self.annexeeBaseVector[3])
		self.mode = 3
	elseif self.mode == 4 then
		self.structureVector[3] =
			StructureMath.toDirection(partSide + self.structureVector[3])
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

function Building:draw()
	local body = self.body
	local vec = self.annexeeBaseVector
	if body and vec and self.mode > 2 then
		local l = StructureMath.addDirectionVector(vec, vec[3], .5)
		local x, y = body:getWorldPoint(l[1], l[2])
		local angle = body:getAngle()

		love.graphics.draw(
			pointerImage,
			x, y, angle,
			1/20, 1/20,
			pointerWidth/2, pointerWidth/2)
	end
end

return Building

require("util")

Selection = {}
Selection.__index = Selection

function Selection.enable(structureList, ship, anchor)
	local self = {}
	setmetatable(self, Selection)

	self.image = love.graphics.newImage("res/images/pointer.png")
	self.width = self.image:getWidth()
	self.structureList = structureList
	self.ship = ship
	self.anchor = anchor

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

	if #structureList > 0 then
		self.index = 1
		return self
	else
		return nil
	end
end

-- Select the previous item in the list.
function Selection:previous()
	self.index = self.index - 1

	-- If we are selecting a structure to annex...
	if self.mode == 1 then
		if self.index < 1 then self.index = #self.structureList end

	-- If we are selecting the block within the annexee...
	elseif self.mode == 2 then
		if self.index < 1 then self.index = #self.annexee.parts end

	-- If we are selecting the side of the annexee block...
	elseif self.mode == 3 then
		if self.index < 1 then self.index = 4 end
		if not self:isSideConnectable() then self:previous() end

	-- If we are selecting the structure to add to...
	elseif self.mode == 4 then
		if self.index < 1 then self.index = #self.structureList + 2 end

		-- Don't select the same structure twice.
		if self.index - 2  == self.annexeeIndex then self:previous() end

	-- If we are selecting a location to place the structure...
	elseif self.mode == 5 then
		if self.index < 1 then self.index = #self.structure.parts end

	-- If we are selecting the side of the block in the structure...
	elseif self.mode == 6 then
		if self.index < 1 then self.index = 4 end
		if not self:isSideConnectable() then self:previous() end

	end
end

-- Select the next item in the list.
function Selection:next()
	self.index = self.index + 1

	-- If we are selecting a structure to add...
	if self.mode == 1 then
		if self.index > #self.structureList then self.index = 1	end

	-- If we are selecting the block within the annexee...
	elseif self.mode == 2 then
		if self.index > #self.annexee.parts then self.index = 1 end

	-- If we are selecting the side of the annexee block...
	elseif self.mode == 3 then
		if self.index > 4 then self.index = 1 end
		if not self:isSideConnectable() then self:next() end

	-- If we are selecting the structure to add to...
	elseif self.mode == 4 then
		if self.index > #self.structureList + 2 then self.index = 1	end

		-- Don't select the same structure twice.
		if self.index - 2 == self.annexeeIndex then	self:next() end

	-- If we are selecting a location to place the structure...
	elseif self.mode == 5 then
		if self.index > #self.structure.parts then self.index = 1 end

	-- If we are selecting the side of the block in the structure...
	elseif self.mode == 6 then
		if self.index > 4 then self.index = 1 end
		if not self:isSideConnectable() then self:next() end

	end
end

-- Confirm the current selection.
-- Return 1 when we are done with selection mode.
function Selection:confirm()
	if self.mode == 1 then
		self.annexeeIndex = self.index
		self.annexee = self.structureList[self.index]
		-- Skip selection mode 2 if there is only one part to choose from.
		if #self.annexee.parts == 1 then
			self.index = 1
			self.annexeePartIndex = self.index
			self.annexeePart = self.annexee.parts[self.index]
			self.mode = self.mode + 1
		end
	elseif self.mode == 2 then
		self.annexeePartIndex = self.index
		self.annexeePart = self.annexee.parts[self.index]
	elseif self.mode == 3 then
		self.annexeeSide = self.index
	elseif self.mode == 4 then
		-- The player's ship and the anchor are at the beginning of the list.
		if self.index == 1 then self.structure = self.ship
		elseif self.index == 2 then self.structure = self.anchor
		else self.structure = self.structureList[self.index - 2] end
		-- Skip selection mode 5 if there is only one part to choose from.
		if #self.structure.parts == 1 then
			self.index = 1
			self.structurePartIndex = self.index
			self.structurePart = self.structure.parts[self.index]
			self.mode = self.mode + 1
		end
	elseif self.mode == 5 then
		self.structurePartIndex = self.index
		self.structurePart = self.structure.parts[self.index]
	elseif self.mode == 6 then
		self.structureSide = self.index
	end

	-- What to do next.
	-- Go to the next mode.
	if self.mode < 6 then
		self.mode = self.mode + 1
		self.index = 0
		self:next()
	-- Annex the structure and exit selection mode.
	elseif self.mode == 6 then
		self.structure:annex(self.annexee, self.annexeePart, self.annexeeSide,
						self.structurePart, self.structureSide)
		table.remove(self.structureList, self.annexeeIndex)
		return 1
	end
end

function Selection:draw(globalOffsetX, globalOffsetY)
	if self.mode == 1 then
		local x = self.structureList[self.index].body:getX()
		local y = self.structureList[self.index].body:getY()
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX + x,
			love.graphics.getHeight()/2 - globalOffsetY + y,
			0, 1, 1, self.width/2, self.width/2)
	elseif self.mode == 2 then
		local x, y = self.annexee:getAbsPartCoords(self.index)
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX + x,
			love.graphics.getHeight()/2 - globalOffsetY + y,
			0, 1, 1, self.width/2, self.width/2)
	elseif self.mode == 3 then
		local x, y = self.annexee:getAbsPartCoords(self.annexeePartIndex)
		local offsetX, offsetY -- move the cursor the side that we are selecting
		if self.index == 1 then
			offsetX, offsetY =
				computeAbsCoords(0, -10, self.annexee.body:getAngle())
		elseif self.index == 2 then
			offsetX, offsetY =
				computeAbsCoords(10, 0, self.annexee.body:getAngle())
		elseif self.index == 3 then
			offsetX, offsetY =
				computeAbsCoords(0, 10, self.annexee.body:getAngle())
		elseif self.index == 4 then
			offsetX, offsetY =
				computeAbsCoords(-10, 0, self.annexee.body:getAngle())
		end
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX + x + offsetX,
			love.graphics.getHeight()/2 - globalOffsetY + y + offsetY,
			0, 1, 1, self.width/2, self.width/2
		)
	elseif self.mode == 4 then
		local x, y
		if self.index == 1 then
			x = self.ship.body:getX()
			y = self.ship.body:getY()
		elseif self.index == 2 then
			x = self.anchor.body:getX()
			y = self.anchor.body:getY()
		else
			x = self.structureList[self.index - 2].body:getX()
			y = self.structureList[self.index - 2].body:getY()
		end
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX + x,
			love.graphics.getHeight()/2 - globalOffsetY + y,
			0, 1, 1, self.width/2, self.width/2)
	elseif self.mode == 5 then
		local x, y = self.structure:getAbsPartCoords(self.index)
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX + x,
			love.graphics.getHeight()/2 - globalOffsetY + y,
			0, 1, 1, self.width/2, self.width/2)
	elseif self.mode == 6 then
		local x, y = self.structure:getAbsPartCoords(self.structurePartIndex)
		local offsetX, offsetY -- move the cursor the side that we are selecting
		if self.index == 1 then
			offsetX, offsetY =
				computeAbsCoords(0, -10, self.structure.body:getAngle())
		elseif self.index == 2 then
			offsetX, offsetY =
				computeAbsCoords(10, 0, self.structure.body:getAngle())
		elseif self.index == 3 then
			offsetX, offsetY =
				computeAbsCoords(0, 10, self.structure.body:getAngle())
		elseif self.index == 4 then
			offsetX, offsetY =
				computeAbsCoords(-10, 0, self.structure.body:getAngle())
		end
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX + x + offsetX,
			love.graphics.getHeight()/2 - globalOffsetY + y + offsetY,
			0, 1, 1, self.width/2, self.width/2
		)
	end
end

function Selection:isSideConnectable()
	local connectable = false
	local sideToCheck

	if self.mode == 3 then
		sideToCheck =
			self.index - self.annexee.partOrient[self.annexeePartIndex] + 1
		if sideToCheck == 0 then sideToCheck = 4 end

		if self.annexeePart.connectableSides[sideToCheck] then
			connectable = true
		end
	elseif self.mode == 6 then
		sideToCheck =
			self.index - self.structure.partOrient[self.structurePartIndex] + 1
		if sideToCheck == 0 then sideToCheck = 4 end

		if self.structurePart.connectableSides[sideToCheck] then
			connectable = true
		end
	end

	return connectable
end

return Selection

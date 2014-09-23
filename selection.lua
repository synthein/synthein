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
		self.annexee = self.structureList[self.index]
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
		self.annexee = self.structureList[self.index]

	-- If we are selecting the block within the annexee...
	elseif self.mode == 2 then
		if self.index < 1 then self.index = #self.annexee.parts end
		self.annexeePart = self.annexee.parts[self.index]
		self.annexeePartIndex = self.index

	-- If we are selecting the side of the annexee block...
	elseif self.mode == 3 then
		if self.index < 1 then self.index = 4 end
		self.orientation = self.index

	-- If we are selecting the structure to add to...
	elseif self.mode == 4 then
		if self.index < 1 then self.index = #self.structureList + 2 end

		-- The player's ship and the anchor are at the beginning of the list.
		if self.index == 1 then self.structure = self.ship
		elseif self.index == 2 then self.structure = self.anchor
		else self.structure = self.structureList[self.index - 2] end

		-- Don't select the same structure twice.
		if self.index - 2  == self.annexeeIndex then
			self:previous()
			return
		end

	-- If we are selecting a location to place the structure...
	elseif self.mode == 5 then
		if self.index < 1 then self.index = #self.structure.parts end
		self.structurePart = self.structure.parts[self.index]
		self.structurePartIndex = self.index

	-- If we are selecting the side of the block in the structure...
	elseif self.mode == 6 then
		if self.index < 1 then self.index = 4 end
		self.side = self.index
	end
end

-- Select the next item in the list.
function Selection:next()
	self.index = self.index + 1

	-- If we are selecting a structure to add...
	if self.mode == 1 then
		if self.index > #self.structureList then self.index = 1	end
		self.annexee = self.structureList[self.index]

	-- If we are selecting the block within the annexee...
	elseif self.mode == 2 then
		if self.index > #self.annexee.parts then self.index = 1 end
		self.annexeePart = self.annexee.parts[self.index]
		self.annexeePartIndex = self.index

	-- If we are selecting the side of the annexee block...
	elseif self.mode == 3 then
		if self.index > 4 then self.index = 1 end
		self.orientation = self.index

	-- If we are selecting the structure to add to...
	elseif self.mode == 4 then
		if self.index > #self.structureList + 2 then self.index = 1	end

		-- The player's ship and the anchor are at the beginning of the list.
		if self.index == 1 then self.structure = self.ship
		elseif self.index == 2 then self.structure = self.anchor
		else self.structure = self.structureList[self.index - 2] end

		-- Don't select the same structure twice.
		if self.index - 2 == self.annexeeIndex then
			self:next()
			return
		end

	-- If we are selecting a location to place the structure...
	elseif self.mode == 5 then
		if self.index > #self.structure.parts then self.index = 1 end
		self.structurePart = self.structure.parts[self.index]
		self.structurePartIndex = self.index

	-- If we are selecting the side of the block in the structure...
	elseif self.mode == 6 then
		if self.index > 4 then self.index = 1 end
		self.side = self.index
	end
end

-- Confirm the current selection.
-- Return 1 when we are done with selection self.mode.
function Selection:confirm()
	if self.mode == 1 then
		self.annexeeIndex = self.index
	end

	if self.mode < 6 then
		self.mode = self.mode + 1
		self.index = 0
		self:next()
	elseif self.mode == 6 then
		self.structure:annex(self.annexee, self.annexeePart, self.orientation,
		                 self.structurePart, self.side)
		table.remove(self.structureList, self.annexeeIndex)
		return 1
	end

	-- Skip unnecessary selection modes.
	if self.mode == 2 then
		if #self.annexee.parts == 1 then
			self:confirm()
			return
		end
	elseif self.mode == 5 then
		if #self.structure.parts == 1 then
			self:confirm()
			return
		end
	end
end

function Selection:draw(globalOffsetX, globalOffsetY)
	if self.mode == 1 then
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX +
				self.annexee.body:getX(),
			love.graphics.getHeight()/2 - globalOffsetY +
				self.annexee.body:getY(),
			0, 1, 1, self.width/2, self.width/2)
	elseif self.mode == 2 then
		local x, y = self.annexee:getAbsPartCoords(self.annexeePartIndex)
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX + x,
			love.graphics.getHeight()/2 - globalOffsetY + y,
			0, 1, 1, self.width/2, self.width/2)
	elseif self.mode == 4 then
		print(self.index)
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX +
				self.structure.body:getX(),
			love.graphics.getHeight()/2 - globalOffsetY +
				self.structure.body:getY(),
			0, 1, 1, self.width/2, self.width/2)
	elseif self.mode == 5 then
		local x, y = self.structure:getAbsPartCoords(self.structurePartIndex)
		love.graphics.draw(
			self.image,
			love.graphics.getWidth()/2 - globalOffsetX + x,
			love.graphics.getHeight()/2 - globalOffsetY + y,
			0, 1, 1, self.width/2, self.width/2)
	end
end

return Selection

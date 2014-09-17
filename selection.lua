Selection = {}
Selection.__index = Selection

function Selection.enable(structureList)
	local self = {}
	setmetatable(self, Selection)

	self.image = love.graphics.newImage("res/images/pointer.png")
	self.structureList = structureList

	if #structureList > 0 then
		self.index = 1
		self.choice = structureList[self.index]
	else
		self:disable()
		return 1
	end

	return self
end

-- Select the previous structure in the list.
function Selection:previous()
	self.index = self.index - 1

	-- If we scroll past the beginning of the list, cycle back to the end.
	if self.index < 1 then
		self.index = #self.structureList
	end

	self.choice = self.structureList[self.index]
end

-- Select the next structure in the list.
function Selection:next()
	self.index = self.index + 1

	-- If we scroll past the end of the list, cycle back to the beginning.
	if self.index > #self.structureList then
		self.index = 1
	end

	self.choice = self.structureList[self.index]
end

-- Confirm the current selection.
function Selection:confirm()
	playerShip:merge(self.choice, self.choice.parts[1], playerShip.parts[#playerShip.parts], "right")
	table.remove(self.structureList, self.index)
end

function Selection:draw(globalOffsetX, globalOffsetY)
	love.graphics.draw(
		self.image,
		love.graphics.getWidth()/2 - globalOffsetX + self.choice.body:getX(),
		love.graphics.getHeight()/2 - globalOffsetY + self.choice.body:getY(),
		0, 1, 1, 2, 2)
end

return Selection

Selection = {}
Selection.__index = Selection

function Selection.enableSelection(structureList)
	local self = {}
	setmetatable(self, Selection)

	self.structureList = structureList

	return self
end

function Selection:confirm()
	local choice = self.structureList[#self.structureList]
	playerShip:merge(choice, choice.parts[1], playerShip.parts[#playerShip.parts], "right")
	table.remove(self.structureList, #self.structureList)
end

function Selection:draw()

end

return Selection

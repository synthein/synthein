local Structure = require("structure")
local InitWorld = require("initWorld")

local World = {}
World.__index = World

function World.create(physics)
	self = {}
	setmetatable(self, World)
	
	self.worldStructures, self.anchor, self.playerShip = InitWorld.init(physics)

	return self
end

function World:getPlayerShip()
	return self.playerShip
end

function World:getStructure(mouseWorldX,mouseWorldY,nonWorldStructures)
	if nonWorldStructures then
		local part, partSide = player:getPartIndex(mouseWorldX, mouseWorldY, 
													   player)
		if part and partSide then
			return structure, part, partSide, i
		end
--		for i, structure in ipairs(player) do
--			local part, partSide = self:partIndexPartsLoop(mouseX, mouseY, 
--														   structure)
--			if part and partSide then
--			return structure, part, partSide, i
--			end
--		end
		local part, partSide = anchor:getPartIndex(mouseWorldX, mouseWorldY, 
													   anchor)
		if part and partSide then
			return structure, part, partSide, i
		end
--		for i, structure in ipairs(anchor) do
--			local part, partSide = self:partIndexPartsLoop(mouseX, mouseY, 
--														   structure)
--			if part and partSide then
--			return structure, part, partSide, i
--			end
--		end
	end
	for i, structure in ipairs(self.worldStructures) do
		local part, partSide = structure:getPartIndex(mouseWorldX, mouseWorldY)
		if part and partSide then
			return structure, part, partSide, i
		end
	end
end

function World:annex(annexee, annexeePart, annexeePartSideClicked, annexeeIndex,
					 structure, structurePart, structurePartSideClicked)
			structure:annex(annexee, annexeePart, 
								 annexeePartSideClicked,
								 structurePart, structurePartSideClicked)
			table.remove(self.worldStructures, annexeeIndex)
end

function World:update(dt)
	self.playerShip:update(dt)
end

function World:draw()
	self.anchor:draw(globalOffsetX, globalOffsetY)
	for i, structure in ipairs(self.worldStructures) do
		structure:draw(globalOffsetX, globalOffsetY)
	end
	self.playerShip:draw(globalOffsetX, globalOffsetY)
end

return World

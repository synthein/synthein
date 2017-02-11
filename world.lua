local Chunk = require("chunk")

local World = {}
World.__index = World

-- The world object contains all of the state information about the game world
-- and is responsible for updating and drawing everything in the game world.
function World.create()
	self = {}
	setmetatable(self, World)

	self.chunks = GridTable.create()
	return self
end

function World:addObject(object, chunkLocation, key)
	if not chunkLocation then
		local x, y = object:getLocation()
		chunkX, chunkY = Chunk.getChunkIndex(x, y)
		chunkLocation = {chunkX, chunkY}
	end
	local chunk = self:getChunk(chunkLocation)
	chunk:addObject(object, key)
end

function World:getChunk(location)
	local x = location[1]
	local y = location[2]
	local chunk = self.chunks:index(x, y)
	if not chunk then
		chunk = Chunk.create({x, y})
		self.chunks:index(x, y, chunk)
	end
	return chunk
end

--Get the structure and part under at the location.
--Also return the side of the part that is closed if there is a part.
function World:getObject(locationX, locationY, key)
	local chunkX, chunkY = Chunk.getChunkIndex(locationX, locationY)
	local chunk = self:getChunk({chunkX, chunkY})
	local object, returnValues
		= chunk:getObject(locationX, locationY, key)
	return object, returnValues
end

--Removes a section of a structure and saves the new structure.
function World:removeSection(structure, partIndex)
	if structure.parts[partIndex].type == "generic" then
		local newStructure = structure:removeSection(partIndex)
		if newStructure then
			self:addObject(newStructure, nil, "structures")
		end
	end
end

--[[
--Merges two structures.
--Any overlapping parts from the annexee are placed in new structures.
function World:annex(annexee, annexeePartIndex, annexeePartSide,
					 structure, structurePartIndex, structurePartSide)
	local newStructures = structure:annex(annexee, annexeePartIndex,
					annexeePartSide, structurePartIndex, structurePartSide)
	for i = 1,#newStructures do
		table.insert(self.structures, newStructures[1])
	end
end
--]]

function World:update(dt)
	local move = self.chunks:loop(Chunk.update, dt)
	
	for i, t in ipairs(move) do
		for j, object in ipairs(t) do
			self:addObject(object[3], object[1], object[2])
		end
	end

end

function World:draw()
	-- Draw all of the chunks.
	self.chunks:loop(Chunk.draw)
end

return World

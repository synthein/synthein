local Chunk = require("chunk")

local World = {}
World.__index = World

-- The world object contains all of the state information about the game world
-- and is responsible for updating and drawing everything in the game world.
function World.create()
	self = {}
	setmetatable(self, World)

	self.chunks = {}
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
	if not self.chunks[y] then
		self.chunks[y] = {}
	end
	if not self.chunks[y][x] then
		self.chunks[y][x] = Chunk.create({x, y})
	end
	return self.chunks[y][x]
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
		self:addObject(newStructure, nil, "structures")
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
	local move = {}
	for keyY, chunkTable in pairs(self.chunks) do
		for keyX, chunk in pairs(chunkTable) do
			m = chunk:update(dt)
			for i, object in ipairs(m) do
				table.insert(move, object)
			end
		end
	end
	
	for i, object in ipairs(move) do
		self:addObject(object[3], object[1], object[2])
	end

end

function World:draw()
	-- Draw all of the chunks.
	for keyY, chunkTable in pairs(self.chunks) do
		for keyX, chunk in pairs(chunkTable) do
			chunk:draw()
		end
	end
end

return World

local Particles = require("particles")
local Shot = require("shot")
local Structure = require("structure")
local Util = require("util")




local Chunk = {}
Chunk.__index = Chunk

Chunk.objects = {
	structures	= Structure,
	shots   	= Shot,
	particles	= Particles
}

Chunk.size = 2000

function Chunk.create(chunkLocation)
	self = {}
	setmetatable(self, Chunk)

	self.chunkLocation = chunkLocation

	for key, value in pairs(Chunk.objects) do
		self[key] = {}
	end
	return self
end

function Chunk:addObject(object, objectKey)
	if objectKey == nil then
		for key, value in pairs(Chunk.objects) do
			if value == object.__index then
				objectKey = key
				break
			end
		end
	end
	if objectKey == nil then
		return
	end
	table.insert(self[objectKey], object)
end

function Chunk.getChunkIndex(x, y)
	return math.floor(x / Chunk.size + 0.5), math.floor(y / Chunk.size + 0.5)
end

function Chunk:getStructure(locationX, locationY)
	for i, structure in ipairs(self.structures) do
		local partIndex, partSide = structure:getPartIndex(locationX, locationY)
		if partIndex and partSide then
			return structure, partIndex, partSide
		end
	end
end

function Chunk:update(dt)
	local move = {}
	local remove = {}
	local create = {}

	local shipLocations = {{},{}}
	for i, structure in ipairs(self.structures) do
		if structure.corePart then
			local team = structure.corePart:getTeam()
			if team then
				if structure.corePart.isPlayer then
					table.insert(shipLocations[team], 
								{structure.body:getX(), structure.body:getY(),true})
				else
					table.insert(shipLocations[team], 
								{structure.body:getX(), structure.body:getY()})
				end
			end
			
		end
	end

	local worldInfo = {shipLocations}

	for key, value in pairs(Chunk.objects) do
		for i, object in ipairs(self[key]) do
			c = object:update(dt, worldInfo)
			for i, o in ipairs(c) do
				table.insert(create, o)
			end

			if object.isDestroyed == true then
				table.insert(remove, {key, i})
			end
			local x1, y1 = Chunk.getChunkIndex(object:getLocation())
			local x2 = self.chunkLocation[1]
			local y2 = self.chunkLocation[2]
			if not (x1 == x2 and y1 == y2) then
				local chunkLocation = {x1, y1}
				table.insert(remove, {key, i})
				table.insert(move, {chunkLocation, key, object})
			end

		end
	end

	for i, object in ipairs(remove) do
		self[object[1]][object[2]] = {"kill"}
	end
	
	for key, value in pairs(Chunk.objects) do
		for i = #self[key],1,-1 do
			if self[key][i][1] == "kill" then
				table.remove(self[key], i)
			end
		end
	end
	
	for i, object in ipairs(create) do
		key = object[1]
		value = Chunk.objects[key]
		newObject = value.create(object[2], object[3], object[4])
		table.insert(self[key], newObject)
	end
	
	return move
end

function Chunk:draw()
	for key, value in pairs(Chunk.objects) do
		for i, object in ipairs(self[key]) do
			object:draw()
		end
	end
end

return Chunk

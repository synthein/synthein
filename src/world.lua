local Particles = require("particles")
local Shot = require("shot")
local Structure = require("structure")
local Util = require("util")
local Settings = require("settings")

local World = {}
World.__index = World

World.objectTypes = {
	structures	= Structure,
	shots   	= Shot,
	particles	= Particles
}

-- The world object contains all of the state information about the game world
-- and is responsible for updating and drawing everything in the game world.
function World.create()
	self = {}
	setmetatable(self, World)

	self.physics = love.physics.newWorld()
	self.physics:setCallbacks(World.beginContact, World.endContact,
							  World.preSolve, World.postSolve)

	self.objects = {}
	for key, value in pairs(World.objectTypes) do
		self.objects[key] = {}
	end

	return self
end

function World.beginContact(a, b, coll)
	--print("beginContact")
	local aSensor = a:isSensor()
	local bSensor = b:isSensor()
	local objectA, objectB
	objectA = a:getUserData()
	objectB = b:getUserData()

	if not aSensor and not bSensor then
		local x, y = coll:getPositions()
		local bodyA = a:getBody()
		local bodyB = b:getBody()
		local sq

		if x and y then
			local aVX, aVY = bodyA:getLinearVelocityFromWorldPoint(x, y)
			local bVX, bVY = bodyB:getLinearVelocityFromWorldPoint(x, y)
			local dVX = aVX - bVX
			local dVY = aVY - bVY
			sqV = (dVX * dVX) + (dVY * dVY)
		else
			sqV = 0
		end

		objectA:collision(b, sqV, {aVX, aVY})
		objectB:collision(a, sqV, {aVX, aVY})
	elseif aSensor then
		objectA:collision(b)
	elseif bSensor then
		objectB:collision(a)
	end
end
 
 
function World.endContact(a, b, coll)
	--print("endContact")
end
 
function World.preSolve(a, b, coll)
	--print("preSolve")
	objectA = a:getUserData()
	objectB = b:getUserData()
	if objectA.isDestroyed or objectB.isDestroyed then
		coll:setEnabled(false)
	end
end
 
function World.postSolve(a, b, coll, normalimpulse, tangentimpulse)
	--print("postSolve")
end

function World:addObject(object, chunkLocation, key)
	if objectKey == nil then
		for key, value in pairs(World.objectTypes) do
			if value == object.__index then
				objectKey = key
				break
			end
		end
	end
	if objectKey == nil then
		return
	end
	table.insert(self.objects[objectKey], object)
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

World.callbackData = {objects = {}}

function World.fixtureCallback(fixture)
	local body = fixture:getBody()
	local object = {body:getUserData(), fixture:getUserData()}
	table.insert(World.callbackData.objects, object)
	return true
end

--Get the structure and part under at the location.
--Also return the side of the part that is closed if there is a part.
function World:getObject(locationX, locationY, key)
	World.callbackData.objects = {}
	local a = locationX
	local b = locationY
	self.physics:queryBoundingBox(a, b, a, b, 
								  World.fixtureCallback)

	for i, object in ipairs(World.callbackData.objects) do
		if object[1] then
			return object[1], object[2], object[2]:getPartSide(locationX, locationY)
		end
	end
--[[
	if key then
		for i, object in ipairs(self.objects[key]) do
			there, returnValues = object:testLocation(locationX, locationY)
			if there then
				return object, returnValues
			end
		end
	else
		for key, value in pair do
			for i, object in ipairs(self.objects[key]) do
				there, returnValues = object:testLocation(locationX, locationY)
				if there then
					return object, returnValues
				end
			end
		end
	end
--]]
	return nil
end

function World:getObjects(key)
	if key then
		return self.objects[key]
	else
		return self.objects
	end
end

--Removes a section of a structure and saves the new structure.
function World:removeSection(structure, part)
	if part.type == "generic" then
		local newStructure = structure:removeSection(structure:findPart(part))
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
	local remove = {}
	local create = {}

	for key, objectTable in pairs(self.objects) do
		for i, object in ipairs(objectTable) do
			c = object:update(dt)
			for i, o in ipairs(c) do
				table.insert(create, o)
			end

			if object.isDestroyed == true then
				table.insert(remove, {key, i})
			end
		end
	end

	for i, object in ipairs(remove) do
		self.objects[object[1]][object[2]] = {"kill"}
	end
	
	for key, value in pairs(World.objectTypes) do
		for i = #self.objects[key],1,-1 do
			if self.objects[key][i][1] == "kill" then
				table.remove(self.objects[key], i)
			end
		end
	end
	
	for i, object in ipairs(create) do
		local key = object[1]
		local value = World.objectTypes[key]
		local newObject = value.create(self.physics, object[2], object[3], object[4])
		table.insert(self.objects[key], newObject)
	end
end

return World

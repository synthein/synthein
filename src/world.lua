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

World.playerHostility = {{false}}

-- The world object contains all of the state information about the game world
-- and is responsible for updating and drawing everything in the game world.
function World.create()
	self = {}
	setmetatable(self, World)

	self.physics = love.physics.newWorld()
	self.physics:setCallbacks(World.beginContact, World.endContact,
							  World.preSolve, World.postSolve)

	self.objects = {}
	local generalHostility = {}
	generalHostility[0]  = false --corepartless structures
	generalHostility[-1] = true  --pirates
	generalHostility[-2] = false --civilians
	generalHostility[-3] = true  --Empire
	generalHostility[-4] = true  --Federation
	
	self.events = {create = {}}
	local teamHostility = {playerHostility = World.playerHostility,
						   general = generalHostility}
	function teamHostility:test(team, otherTeam)
		local max = math.max(team, otherTeam)
		local min = math.min(team, otherTeam)
		if min > 0 then
			return self.playerHostility[team][otherTeam]
		elseif max > 0 then
			return self.general[min]
		elseif max > -3 then
			return self.general[max]
		else
			return team ~= otherTeam
		end
	end

	self.info = {events = self.events, physics = self.physics, 
					teamHostility = teamHostility}

	for key, value in pairs(World.objectTypes) do
		self.objects[key] = {}
	end

	self.boarders = nil

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

function World:update(dt)
	local nextBoarders = {0, 0, 0, 0}

	for key, objectTable in pairs(self.objects) do
		for i = #objectTable,1,-1 do
			local object = objectTable[i]
			if object.isDestroyed == false then
				local objectX, objectY = object:getLocation()
				if key == "structures" and object.corePart and 
						object.corePart:getTeam() > 0 then
					if objectX < nextBoarders[1] then
						nextBoarders[1] = objectX
					elseif objectX > nextBoarders[3]then
						nextBoarders[3] = objectX
					end
					if objectY < nextBoarders[2] then
						nextBoarders[2] = objectY
					elseif objectY > nextBoarders[4] then
						nextBoarders[4] = objectY
					end
				end

				object:update(dt, self.info)

				if (self.boarders and (objectX < self.boarders[1] or
									   objectY < self.boarders[2] or
									   objectX > self.boarders[3] or
									   objectY > self.boarders[4])) then
					object:destroy()
				end
			end

			if object.isDestroyed == true then
				table.remove(self.objects[key], i)
			end
		end
	end

	self.boarders = nextBoarders
	self.boarders[1] = self.boarders[1] - 10000
	self.boarders[2] = self.boarders[2] - 10000
	self.boarders[3] = self.boarders[3] + 10000
	self.boarders[4] = self.boarders[4] + 10000
	
	for i, object in ipairs(self.events.create) do
		local key = object[1]
		local value = World.objectTypes[key]
		local newObject = value.create(self.info, object[2], object[3])
		table.insert(self.objects[key], newObject)
	end
	self.events.create = {}
end

return World

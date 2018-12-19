local Particles = require("world/particles")
local Shot = require("world/shot")
local Structure = require("world/structure")

local World = class()

World.objectTypes = {
	structure	= Structure,
	shot   	= Shot,
	particles	= Particles
}

-- The world object contains all of the state information about the game world
-- and is responsible for updating and drawing everything in the game world.
function World:__create(playerHostility)

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
	local teamHostility = {playerHostility = playerHostility,
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

	self.boarders = nil
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
		local sqV, aVX, aVY, bVX, bVY

		if x and y then
			aVX, aVY = bodyA:getLinearVelocityFromWorldPoint(x, y)
			bVX, bVY = bodyB:getLinearVelocityFromWorldPoint(x, y)
			local dVX = aVX - bVX
			local dVY = aVY - bVY
			sqV = (dVX * dVX) + (dVY * dVY)
		else
			sqV = 0
		end

		objectA:collision(b, sqV, {aVX, aVY})
		objectB:collision(a, sqV, {aVX, aVY})
	elseif aSensor and not bSensor then
		objectA:collision(b)
	elseif bSensor and not aSensor then
		objectB:collision(a)
	end
end


function World.endContact() --(a, b, coll)
	--print("endContact")
end

function World.preSolve(a, b, coll)
	--print("preSolve")
	local objectA = a:getUserData()
	local objectB = b:getUserData()
	if objectA.isDestroyed or objectB.isDestroyed then
		coll:setEnabled(false)
	end
end

function World.postSolve() --(a, b, coll, normalimpulse, tangentimpulse)
	--print("postSolve")
end

function World:addObject(object, objectKey)
	table.insert(self.objects, object)
end

World.callbackData = {objects = {}}



--Get the structure and part under at the location.
--Also return the side of the part that is closed if there is a part.
function World:getObject(locationX, locationY)
	local objects = {}

	function callback(fixture)
		local body = fixture:getBody()
		local object = {body:getUserData(), fixture:getUserData()}
		table.insert(objects, object)
		return true
	end

	local a = locationX
	local b = locationY
	self.physics:queryBoundingBox(a, b, a, b,callback)

	for _, object in ipairs(objects) do
		if object[1] then
			if object[1]:type() == "structure" then
				object[3] = object[2]:getPartSide(locationX, locationY)
			end
			return unpack(object)
		end
	end

	return nil
end

function World:getObjects()
	return self.objects
end

function World:update(dt)
	self.physics:update(dt)

	local nextBoarders = {0, 0, 0, 0}

	for i, object in ipairs(self.objects) do
		if object.isDestroyed == false then
			local objectX, objectY = object:getLocation():getXY()

			if object:type() == "structure" and object.corePart and
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

			object:update(dt)

			if (self.boarders and (objectX < self.boarders[1] or
								   objectY < self.boarders[2] or
								   objectX > self.boarders[3] or
								   objectY > self.boarders[4])) then
				object:destroy()
			end
		end

		if object.isDestroyed == true then
			table.remove(self.objects, i)
		end
	end

	self.boarders = nextBoarders
	self.boarders[1] = self.boarders[1] - 10000
	self.boarders[2] = self.boarders[2] - 10000
	self.boarders[3] = self.boarders[3] + 10000
	self.boarders[4] = self.boarders[4] + 10000

	for _, object in ipairs(self.events.create) do
		local objectClass = World.objectTypes[object[1]]
		local newObject = objectClass(self.info, object[2], object[3])
		table.insert(self.objects, newObject)
	end
	self.events.create = {}
end

return World

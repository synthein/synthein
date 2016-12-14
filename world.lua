local Particles = require("particles")
local Shot = require("shot")
local Structure = require("structure")
local Util = require("util")

local World = {}
World.__index = World

-- The world object contains all of the state information about the game world
-- and is responsible for updating and drawing everything in the game world.
function World.create()
	self = {}
	setmetatable(self, World)
	self.teamHostility = { {false, true},
						   {true, false} }
	self.structures = {}
	self.shots = {}
	self.particles = {}

	love.physics.setMeter(20) -- there are 20 pixels per meter
	Structure.setPhysics(love.physics.newWorld())
	return self
end

--Add a structure into the world.
function World:createStructure(shipTable, location, data)
	local structure = Structure.create(shipTable, location, data)
	table.insert(self.structures, structure)
	return structure
end

--Get the structure and part under at the location.
--Also return the side of the part that is closed if there is a part.
function World:getStructure(locationX, locationY)
	for i, structure in ipairs(self.structures) do
		local part, partSide = structure:getPartIndex(locationX, locationY)
		if part and partSide then
			return structure, part, partSide
		end
	end
end

--Removes a section of a structure and saves the new structure.
function World:removeSection(structure, part)
	if part.type == "generic" then
		local newStructure = structure:removeSection(part)
		table.insert(self.structures, newStructure)
	end
end

--Merges two structures.
--Any overlapping parts from the annexee are placed in new structures.
function World:annex(annexee, annexeePart, annexeePartSideClicked, annexeeIndex,
					 structure, structurePart, structurePartSideClicked)
	local newStructures = structure:annex(annexee, annexeePart, annexeePartSideClicked,
	                structurePart, structurePartSideClicked)
	for i = 1,#newStructures do
		table.insert(self.structures, newStructures[1])
	end
end

--Creates a shot from the part location.
function World:shoot(structure, part)
	local index = structure:findPart(part)
	local x, y, angle = structure:getAbsPartCoords(index)
	table.insert(self.shots, Shot.create(x, y, angle, structure, part))
end

--Applies damage to a part.
--If the part is Destroyed then it creates a particle effect.
function World:partDamage(structure, part)
	part:takeDamage()
	if part.destroy then
		local partIndex = structure:findPart(part)
		x, y = structure:getAbsPartCoords(partIndex)
		table.insert(self.particles, Particles.newExplosion(x, y))
		structure:removePart(partIndex)
	end
end

function World:update(dt)
	-- Update all of the objects in the world.
	--
	-- Iterating through the tables in world needs to be in reverse so that we
	-- can remove objects from to table as we go along.
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
	local aiData = {self.teamHostility, shipLocations}

	-- Update all of the structues.
	for i=#self.structures, 1, -1 do
		if self.structures[i].isDestroyed == true then
			table.remove(self.structures, i)
		else
		self.structures[i]:update(dt, aiData)
		end
	end

	-- Update the shots.
	for i=#self.shots,1,-1 do
		shotX, shotY, shotTime = self.shots[i]:update(dt)
		local structureHit, partHit = self:getStructure(shotX,shotY)
		local hit =
			structureHit and
			structureHit ~= self.shots[i].sourceStructure and
			partHit and
			partHit ~= self.shots[i].sourcePart
		if self.shots[i].destroy == true or hit then
			table.remove(self.shots, i)
			if hit then
				self:partDamage(structureHit, partHit)
			end
		end
	end

	-- Update the particles.
	for i=#self.particles,1,-1  do
		if self.particles[i].time <= 0 then
			table.remove(self.particles, i)
		else
			self.particles[i]:update(dt)
		end
	end
end

function World:draw()
	-- Draw all of the structures.
	for i, structure in ipairs(self.structures) do
		structure:draw()
	end

	-- Draw the shots.
	for i, shot in ipairs(self.shots) do
		shot:draw()
	end

	-- Draw the particles.
	for i, particle in ipairs(self.particles) do
		particle:draw()
	end
end

return World

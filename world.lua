local AI = require("ai")
local InitWorld = require("initWorld")
local Particles = require("particles")
local Shot = require("shot")
local Structure = require("structure")

local World = {}
World.__index = World

-- The world object contains all of the state information about the game world
-- and is responsible for updating and drawing everything in the game world.
function World.create(physics)
	self = {}
	setmetatable(self, World)
	
	self.worldStructures, self.anchor, self.playerShip, self.aiShips, self.physics = InitWorld.init(physics)
	
	self.ais = {}
	for i, aiShip in ipairs(self.aiShips) do
		table.insert(self.ais, AI.create(aiShip, 2))
	end

	self.shots = {}
	self.particles = {}
	return self
end

function World:getPlayerShip()
	return self.playerShip
end

function World:getStructure(locationX,locationY)
	local part, partSide = self.playerShip:getPartIndex(locationX, locationY, 
												   player)
	if part and partSide then
		return self.playerShip, part, partSide, i
	end
--		for i, structure in ipairs(player) do
--			local part, partSide = self:partIndexPartsLoop(mouseX, mouseY, 
--														   structure)
--			if part and partSide then
--			return structure, part, partSide, i
--			end
--		end
	local part, partSide = self.anchor:getPartIndex(locationX, locationY, 
												   anchor)
	if part and partSide then
		return self.anchor, part, partSide, i
	end
	
--		for i, structure in ipairs(anchor) do
--			local part, partSide = self:partIndexPartsLoop(mouseX, mouseY, 
--														   structure)
--			if part and partSide then
--			return structure, part, partSide, i
--			end
--		end
	structure, part, partSide, i = self:getAIShips(locationX, locationY)
	if structure and part and partSide and i then
		return structure, part, partSide, i
	end
	structure, part, partSide, i = self:getWorldStructure(locationX, locationY)
	if structure and part and partSide and i then
		return structure, part, partSide, i
	end
end

function World:getWorldStructure(locationX, locationY)
	for i, structure in ipairs(self.worldStructures) do
		local part, partSide = structure:getPartIndex(locationX, locationY)
		if part and partSide then
			return structure, part, partSide, i
		end
	end
end

function World:getAIShips(locationX, locationY)
	for i, structure in ipairs(self.aiShips) do
		local part, partSide = structure:getPartIndex(locationX, locationY)
		if part and partSide then
			return structure, part, partSide, i
		end
	end
end

function World:removeSection(structure, part)
	if part.type == "generic" then
		local newStructure = structure:removeSection(self.physics, part)
		table.insert(self.worldStructures, newStructure)
	end
end

function World:annex(annexee, annexeePart, annexeePartSideClicked, annexeeIndex,
					 structure, structurePart, structurePartSideClicked)
	structure:annex(annexee, annexeePart, annexeePartSideClicked,
	                structurePart, structurePartSideClicked)
--	table.remove(self.worldStructures, annexeeIndex)
end

function World:shoot(structure, part)
	local index = structure:findPart(part)
	local x, y, angle = structure:getAbsPartCoords(index)
	table.insert(self.shots, Shot.create(x, y, angle, structure, part))
end

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
	-- Update all of the structues.
	for i, structure in ipairs(self.worldStructures) do
		if #structure.parts == 0 then
			table.remove(self.worldStructures, i)
		else
		structure:update(dt, self.playerShip)
		end
	end
	self.playerShip:update(dt)
	self.anchor:update(dt)
	for i, ai in ipairs(self.ais) do
		if #ai.ship.parts == 0 then
			table.remove(self.ais, i)
		else
		ai:update(dt, self.playerShip)
		end
	end

	-- Update the shots.
	for i, shot in ipairs(self.shots) do
		shotX, shotY, shotTime = shot:update(dt)
		local structureHit, partHit = self:getStructure(shotX,shotY)
		local hit = structureHit and structureHit ~= shot.sourceStructure and 
					partHit and partHit ~=shot.sourcePart
		if shot.destroy == true or hit then
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
	self.anchor:draw(globalOffsetX, globalOffsetY)
	for i, structure in ipairs(self.worldStructures) do
		structure:draw(globalOffsetX, globalOffsetY)
	end
	for i, aiShip in ipairs(self.aiShips) do
		aiShip:draw(globalOffsetX, globalOffsetY)
	end
	self.playerShip:draw(globalOffsetX, globalOffsetY)

	-- Draw the shots.
	for i, shot in ipairs(self.shots) do
		shot:draw(globalOffsetX, globalOffsetY)
	end

	-- Draw the particles.
	for i, particle in ipairs(self.particles) do
		particle:draw(globalOffsetX, globalOffsetY)
	end
end

return World

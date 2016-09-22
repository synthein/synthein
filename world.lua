local AI = require("ai")
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
	teamHostility = { {false, true},
					  {true, false} }
	self.structures = {}
	self.ais = {}
	self.shots = {}
	self.particles = {}

	love.physics.setMeter(20) -- there are 20 pixels per meter
	Structure.setPhysics(love.physics.newWorld())
	return self
end

function World:setPlayerShip(ship)
	self.playerShip = ship
end

function World:getPlayerShip()
	return self.playerShip
end

function World:createStructure(shipTable, location)
	local structure = Structure.create(shipTable, location)
	table.insert(self.structures, structure)
	return structure
end

function World:getStructure(locationX,locationY)
--	local part, partSide = self.playerShip:getPartIndex(locationX, locationY,
--												   player)
--	if part and partSide then
--		return self.playerShip, part, partSide, i
--	end
--		for i, structure in ipairs(player) do
--			local part, partSide = self:partIndexPartsLoop(mouseX, mouseY,
--														   structure)
--			if part and partSide then
--			return structure, part, partSide, i
--			end
--		end
--	local part, partSide = self.anchor:getPartIndex(locationX, locationY,
--												   anchor)
--	if part and partSide then
--		return self.anchor, part, partSide, i
--	end

--		for i, structure in ipairs(anchor) do
--			local part, partSide = self:partIndexPartsLoop(mouseX, mouseY,
--														   structure)
--			if part and partSide then
--			return structure, part, partSide, i
--			end
--		end
--	structure, part, partSide, i = self:getAIShips(locationX, locationY)
--	if structure and part and partSide and i then
--		return structure, part, partSide, i
--	end
	structure, part, partSide, i = self:getStructure(locationX, locationY)
	if structure and part and partSide and i then
		return structure, part, partSide, i
	end
end

function World:isMouseInsidePart(structure, part)
	local mouseX, mouseY = love.mouse.getPosition()
	local partX, partY, partAngle = structure:getAbsPartCoords(structure:findPart(part))
	local partSide = Util.vectorAngle(
		mouseWorldX - partX,
		mouseWorldY - partY) - partAngle
	a, b = Util.vectorComponents(Util.vectorMagnitude(mouseWorldX - partX, mouseWorldY - partY), partSide)
	a = Util.absVal(a)
	b = Util.absVal(b)
	return Util.max(a,b) < 10
end


function World:getStructure(locationX, locationY)
	for i, structure in ipairs(self.structures) do
		local part, partSide = structure:getPartIndex(locationX, locationY)
		if part and partSide then
			return structure, part, partSide, i
		end
	end
end

function World:removeSection(structure, part)
	if part.type == "generic" then
		local newStructure = structure:removeSection(part)
		table.insert(self.structures, newStructure)
	end
end

function World:annex(annexee, annexeePart, annexeePartSideClicked, annexeeIndex,
					 structure, structurePart, structurePartSideClicked)
	local newStructures = structure:annex(annexee, annexeePart, annexeePartSideClicked,
	                structurePart, structurePartSideClicked)
--	table.remove(self.worldStructures, annexeeIndex)
	for i = 1,#newStructures do
		table.insert(self.worldStructures, newStructures[1])
	end
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
	-- Update all of the objects in the world.
	--
	-- Iterating through the tables in world needs to be in reverse so that we
	-- can remove objects from to table as we go along.


	-- Update all of the structues.
	for i=#self.structures, 1, -1 do
		if self.structures[i].isDestroyed == true then
			table.remove(self.structures, i)
		else
		self.structures[i]:update(dt, self.playerShip)
		end
	end
	-- Update all of the ais.
	for i, ai in ipairs(self.ais) do
		local x = ai.ship.body:getX()
		local y = ai.ship.body:getY()
		local targetX, target, distance, target
		for j, aiTarget in ipairs(self.ais) do
			if teamHostility[ai.team][aiTarget.team] then
				targetX = aiTarget.ship.body:getX()
				targetY = aiTarget.ship.body:getY()
				if distance then
					d = Util.vectorMagnitude(targetX - x, targetY - y)
					if d < distance then
						target = aiTarget.ship
						distance = d
					end
				else
					target = aiTarget.ship
					distance = Util.vectorMagnitude(targetX - x, targetY - y)
				end
			end
		end
		if teamHostility[ai.team][1] then
			targetX = self.playerShip.body:getX()
			targetY = self.playerShip.body:getY()
			if distance then
				d = Util.vectorMagnitude(targetX - x, targetY - y)
				if d < distance then
					target = self.playerShip
					distance = d
				end
			else
				target = self.playerShip
				distance = Util.vectorMagnitude(targetX - x, targetY - y)
			end
		end
		if #ai.ship.parts == 0 then
			table.remove(self.ais, i)
		else
			ai:update(dt, self.playerShip, target)
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

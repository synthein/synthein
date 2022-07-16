local Building = require("building")
local CircleMenu = require("circleMenu")
local vector = require("vector")

local Selection = {}
Selection.__index = Selection

function Selection.create(world, team)
	local self = {}
	setmetatable(self, Selection)

	self.world = world
	self.team = team

	self.build = nil
	self.sturcture = nil
	self.partIndex = nil

	return self
end

local function getPartSide(structure, partLocation, cursorX, cursorY)
	local cursorX, cursorY = structure.body:getLocalPoint(cursorX, cursorY)
	local netX , netY = cursorX - partLocation[1], cursorY - partLocation[2]
	local netXSq, netYSq = netX * netX, netY * netY

	local a = netXSq > netYSq and 1 or 0
	local b = netY - netX < 0 and 2 or 0
	return 1 + a + b, netXSq <= .25 and netYSq <= .25
end

function Selection:pressed(cursorX, cursorY, order)
	local structure = self.world:getObject(cursorX, cursorY)
	local part, partSide
	if structure then part, partSide = structure:findPart(cursorX, cursorY) end
	if structure and structure:type() == "structure" and part then
		local build = self.build
		local team = structure:getTeam()
		if build then
			if order == "build" then
				if build.mode == 3 then
					if team == 0 or team == self.team then
						self.structure = structure
						self.part = part
						if build:setStructure(structure, part) then
							self.structure = nil
							self.part = nil
							self.build = nil
						end
					end
				end
			elseif order == "destroy" then
				self.structure = nil
				self.part = nil
				self.build = nil
			end
		else
			if order == "build" then
				if team ~= 0 then
					local corePart = structure.corePart
					if corePart == part then
						if team == self.team and corePart.modules.ai then
							self.structure = structure
							self.part = part
						end
					end
				else
					self.build = Building.create()
					self.build:setAnnexee(structure, part)
					self.structure = structure
					self.part = part
				end
			elseif order == "destroy" then
				local corePart = structure.corePart
				if team == 0 or (team == self.team and part ~= corePart) then
					structure:disconnectPart(part.location)
				end
			end
		end

	else
		if order == "destroy" then
			self.structure = nil
			self.part = nil
			self.build = nil
		end
	end
end

function Selection:released(cursorX, cursorY)
	local structure = self.structure
	local part = self.part
	if structure and part then
		local l = part.location
		local partSide, withinPart = getPartSide(structure, l, cursorX, cursorY)
		if not withinPart then
			if self.build then

				if structure:testEdge({l[1], l[2], partSide}) then
					self.build:setSide(partSide)
					if self.build.mode == 5 then
						self.build = nil
					end
				else
					self.build = nil
				end
			else
				local x, y = body:getWorldPoints(l[1], l[2])
				local strength = self.part:getMenu()
				local newAngle = vector.angle(cursorX - x, cursorY - y)
				local index = self.angleToIndex(newAngle, #strength)
				self.part:runMenu(index)
			end
			self.structure = nil
			self.partSide = nil
		else
			if not self.build then
				self.structure = nil
				self.partSide = nil
			end
		end
	end
end

function Selection.angleToIndex(angle, length)
	local index = math.floor(((-angle/math.pi + 0.5) * length + 1)/2 % length + 1)
	return index
end

function Selection:draw(cursorX, cursorY)
	local structure = self.structure
	local part = self.part
	local build = self.build
	if structure and part then
		local location = part.location
		local partX, partY = unpack(location)
		local partSide = getPartSide(structure, location, cursorX, cursorY)

		local strength, lables
		if build then
			local indexReverse = {1, 4, 3, 2}
			strength = {}
			local l = {partX, partY}
			for i = 1,4 do
				l[3] = i
				local _, partB, connection = structure:testEdge(l)
				local connectable = not partB and connection
				local highlight = i == partSide
				local brightness = highlight and 2 or 1
				strength[indexReverse[i]] = connectable and brightness or 0
			end
		else
			angle = 0
			strength, lables = part:getMenu()
			local newAngle = vector.angle(cursorX - x, cursorY - y)
			local index = self.angleToIndex(newAngle, #strength)
			if strength[index] == 1 then
				strength[index] = 2
			end
		end
		if strength then
			local body = structure.body
			local x, y = body:getWorldPoints(partX, partY)
			local angle = body:getAngle()
			CircleMenu.draw(x, y, angle, 1, strength, lables)
		end
	end
	if build then
		build:draw()
	end
end

return Selection

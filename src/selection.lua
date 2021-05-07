local Building = require("building")
local CircleMenu = require("circleMenu")
local Util = require("util")

local Selection = {}
Selection.__index = Selection

function Selection.create(world, team, camera)
	local self = {}
	setmetatable(self, Selection)

	self.world = world
	self.team = team
	self.camera = camera
	self.circleMenu = CircleMenu.create(self.camera)

	self.build = nil
	self.sturcture = nil
	self.partIndex = nil

	return self
end

function Selection:pressed(cursorX, cursorY, order)
	local structure = self.world:getObject(cursorX, cursorY)
	local part, partSide
	if structure then part, partSide = structure:findPart(cursorX, cursorY) end

	if structure and structure:type() == "structure" and part then
		if self.build then
			if order == "build" then
				if self.build.mode == 3 then
					if not structure.corePart or
							structure.corePart:getTeam() == self.team then
						self.structure = structure
						self.part = part
						if self.build:setStructure(structure, part) then
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
				if structure.corePart then
					local corePart = structure.corePart
					if corePart == part then
						if corePart:getTeam() == self.team and corePart.ai then
							self.structure = structure
							self.part = part
						end
					end
				else
					self.build = Building.create(self.world, self.camera)
					self.build:setAnnexee(structure, part)
					self.structure = structure
					self.part = part
				end
			elseif order == "destroy" then
				local corePart = structure.corePart
				local team = structure:getTeam()
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
	if self.structure and self.part then
		local partSide = self.part:getPartSide(cursorX, cursorY)
		local withinPart = self.part:withinPart(cursorX, cursorY)
		local x, y = self.part:getWorldLocation(self.partIndex):getXY()
		if not withinPart then
			if self.build then
				if self.build:setSide(partSide) then
					self.build = nil
				end
			else
				local strength = self.part:getMenu()
				local newAngle = Util.vectorAngle(cursorX - x, cursorY - y)
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
	if self.structure and self.part then
		local partSide = self.part:getPartSide(cursorX, cursorY)
		local x, y, angle = self.part:getWorldLocation():getXYA()
		local strength, lables
		if self.build then
			local connectableSides = self.part.connectableSides
			strength = {
				connectableSides[1] and 1 or 0,
				connectableSides[4] and 1 or 0,
				connectableSides[3] and 1 or 0,
				connectableSides[2] and 1 or 0
			}
			local indexReverse = {1, 4, 3, 2}
			local i = indexReverse[partSide]

			strength[i] = strength[i] * 2
		else
			angle = 0
			strength, lables = self.part:getMenu()
			local newAngle = Util.vectorAngle(cursorX - x, cursorY - y)
			local index = self.angleToIndex(newAngle, #strength)
			if strength[index] == 1 then
				strength[index] = 2
			end
		end
		if strength then
			self.circleMenu:draw(x, y, angle, 1, strength, lables)
		end
	end
	if self.build then
		self.build:draw()
	end
end

return Selection

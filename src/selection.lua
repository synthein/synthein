local StructureMath = require("world/structureMath")
local Building = require("building")
local CircleMenu = require("circleMenu")
local vector = require("syntheinrust").vector

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

	self.assign = nil

	self.buildingOnStructureListeners = {}
	self.doneBuildingOnStructureListeners = {}

	return self
end

function Selection:cursorpressed(cursor, control)
	local structure = self.world:getObject(cursor.x, cursor.y)
	local part
	if structure then part = structure:findPart(cursor.x, cursor.y) end
	if structure and structure.type == "structure" and part then
		local build = self.build
		local team = structure.body:getUserData().team
		if build then
			if control.ship  == "build" then
				if build.mode == 3 then
					if team == 0 or team == self.team then
						self.structure = structure
						self.part = part
						if build:setStructure(structure, part) then
							self.structure = nil
							self.part = nil
							self.build = nil
						end
						self:signalBuildingOnStructure()
					end
				end
			elseif control.ship == "destroy" then
				self.structure = nil
				self.part = nil
				self.build = nil
			end
		elseif self.assign then
			self.assign.leader = structure
			self.assign = nil
		else
			if control.ship == "build" then
				if team ~= 0 then
					local corePart = structure.corePart
					if corePart == part then
						if team == self.team and corePart.modules.drone then
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
			elseif control.ship == "destroy" then
				local corePart = structure.corePart
				if team == 0 or (team == self.team and part ~= corePart) then
					structure:disconnectPart(part.location)
				end
			end
		end

	else
		if control.ship == "destroy" then
			self.structure = nil
			self.part = nil
			self.build = nil
		end
	end
end

function Selection:cursorreleased(cursor, control)
	local structure = self.structure
	local part = self.part
	if structure and part then
		local l = part.location
		local partSide, withinPart = StructureMath.getPartSide(structure, l, cursor.x, cursor.y)
		local build = self.build
		if not withinPart then
			if build then
				if structure:testEdge({l[1], l[2], partSide}) then
					build:setSide(partSide)
					if build.mode == 5 then
						self.build = nil
						self:signalDoneBuildingOnStructure()
					end
				else
					self.build = nil
				end
			else
				local body = structure.body
				local x, y = body:getWorldPoints(l[1], l[2])
				local strength = part:getMenu()
				local newAngle = vector.angle(cursor.x - x, cursor.y - y)
				local index = CircleMenu.angleToIndex(newAngle, #strength)
				local option = self.part:runMenu(index, body)
				if option == "assign" then
					self.assign = self.part
				end
			end
			self.structure = nil
			self.partSide = nil
		else
			if not build then
				self.structure = nil
				self.partSide = nil
			end
		end
	end
end

function Selection:isBuildingOnStructure()
	return self.build and self.build.structure
end

function Selection:whenBuildingOnStructure(func)
	table.insert(self.buildingOnStructureListeners, func)
end

function Selection:signalBuildingOnStructure()
	for _, func in ipairs(self.buildingOnStructureListeners) do
		func()
	end
end

function Selection:whenDoneBuildingOnStructure(func)
	table.insert(self.doneBuildingOnStructureListeners, func)
end

function Selection:signalDoneBuildingOnStructure()
	for _, func in ipairs(self.doneBuildingOnStructureListeners) do
		func()
	end
end

return Selection

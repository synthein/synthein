local StructureMath = require("world/structureMath")
local CircleMenu = require("circleMenu")
local Building = require("syntheinrust").building
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
			if control.ship == "build" then
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
				if structure:testEdge({ l[1], l[2], partSide }) then
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

function Selection:draw(cursor, zoom)
	local structure = self.structure
	local part = self.part
	local build = self.build
	if structure and part then
		local location = part.location
		local partX, partY = unpack(location)
		local body = structure.body
		local menuRotation -- Body angle if building else 0

		local strength, labels
		if build then
			menuRotation = body:getAngle()
			strength = {}
			local indexReverse = {1, 4, 3, 2}
			local x, y = body:getWorldPoints(partX, partY)
			local menuToCursorAngle = vector.angle(cursor.worldX - x, cursor.worldY - y)
			local partSide = CircleMenu.angleToIndex(-menuRotation + menuToCursorAngle, 4)
			local l = {partX, partY}
			for i = 1,4 do
				l[3] = indexReverse[i]
				local _, partB, connection = structure:testEdge(l)
				local connectable = not partB and connection
				local highlight = i == partSide
				local brightness = highlight and 2 or 1
				strength[i] = connectable and brightness or 0
			end
		else
			menuRotation = 0
			local x, y = body:getWorldPoints(partX, partY)
			strength, labels = part:getMenu()
			local menuToCursorAngle = vector.angle(cursor.worldX - x, cursor.worldY - y)
			local index = CircleMenu.angleToIndex(menuToCursorAngle, #strength)
			if strength[index] == 1 then
				strength[index] = 2
			end
		end
		if strength then
			local x, y = body:getWorldPoints(partX, partY)
			CircleMenu.draw(x, y, menuRotation, 1, strength, labels)
		end
	end
	if build then

		local body = build.body
		local vec = build.annexeeBaseVector
		if body and vec and build.mode > 2 then
			local l = StructureMath.addDirectionVector(vec, vec[3], .5)
			local x, y = body:getWorldPoint(l[1], l[2])
			local angle = body:getAngle()

			love.graphics.draw(
				cursor.image,
				x, y, angle,
				1/zoom, 1/zoom,
				halfCursorWidth, halfCursorWidth)
		end
	end
	local assign = self.assign
	if assign then
		local body = assign.modules.hull.fixture:getBody()
		local x, y  = body:getPosition()
		local angle = body:getAngle()

		love.graphics.draw(
			cursor.image,
			x, y, angle,
			1/zoom, 1/zoom,
			halfCursorWidth, halfCursorWidth)
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

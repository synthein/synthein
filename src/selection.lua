local StructureMath = require("world/structureMath")
local Building = require("building")
local CircleMenu = require("circleMenu")
local vector = require("vector")

local pointerImage = love.graphics.newImage("res/images/pointer.png")
local pointerWidth = pointerImage:getWidth()

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

local function angleToIndex(angle, length)
	local index = math.floor(((-angle/math.pi + 0.5) * length + 1)/2 % length + 1)
	return index
end

function Selection:pressed(cursorX, cursorY, order)
	local structure = self.world:getObject(cursorX, cursorY)
	local part
	if structure then part = structure:findPart(cursorX, cursorY) end
	if structure and structure:type() == "structure" and part then
		local build = self.build
		local team = structure.body:getUserData().team
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
		elseif self.assign then
			self.assign.leader = structure
			self.assign = nil
		else
			if order == "build" then
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
		local build = self.build
		if not withinPart then
			if build then
				if structure:testEdge({l[1], l[2], partSide}) then
					build:setSide(partSide)
					if build.mode == 5 then
						self.build = nil
					end
				else
					self.build = nil
				end
			else
				local body = structure.body
				local x, y = body:getWorldPoints(l[1], l[2])
				local strength = part:getMenu()
				local newAngle = vector.angle(cursorX - x, cursorY - y)
				local index = angleToIndex(newAngle, #strength)
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

function Selection:draw(cursorX, cursorY)
	local structure = self.structure
	local part = self.part
	local build = self.build
	if structure and part then
		local location = part.location
		local partX, partY = unpack(location)
		local partSide = getPartSide(structure, location, cursorX, cursorY)
		local body = structure.body
		local angle -- Body angle if building else 0

		local strength, lables
		if build then
			angle = body:getAngle()
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
			local x, y = body:getWorldPoints(partX, partY)
			strength, lables = part:getMenu()
			local newAngle = vector.angle(cursorX - x, cursorY - y)
			local index = angleToIndex(newAngle, #strength)
			if strength[index] == 1 then
				strength[index] = 2
			end
		end
		if strength then
			local x, y = body:getWorldPoints(partX, partY)
			CircleMenu.draw(x, y, angle, 1, strength, lables)
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
				pointerImage,
				x, y, angle,
				1/20, 1/20,
				pointerWidth/2, pointerWidth/2)
		end
	end
	local assign = self.assign
	if assign then
		local body = assign.modules.hull.fixture:getBody()
		local x, y  = body:getPosition()
		local angle = body:getAngle()
		love.graphics.draw(
			pointerImage,
			x, y, angle,
			1/20, 1/20,
			pointerWidth/2, pointerWidth/2)
	end
end

return Selection

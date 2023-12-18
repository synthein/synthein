local StructureMath = {}

local unitVectors = {{0, 1}, {-1, 0}, {0, -1}, {1, 0}}

local piOverTwo = math.pi / 2
function StructureMath.directionToAngle(d)
	return (d - 1) * piOverTwo
end

function StructureMath.toDirection(value)
	return (value - 2) % 4 + 1
end

function StructureMath.addDirections(a, b)
	return (a + b - 2) % 4 + 1
end

function StructureMath.subDirections(a, b)
	return (a - b) % 4 + 1
end

function StructureMath.step(vector)
	return vector[1] + unitVectors[vector[3]][1], vector[2] + unitVectors[vector[3]][2]
end

function StructureMath.addUnitVector(vector, direction)
	return {vector[1] + unitVectors[direction][1],
			vector[2] + unitVectors[direction][2],
			vector[3]}
end

function StructureMath.adjacentPoints(location)
	local points = {}
        for i = 1,4 do
                table.insert(points, StructureMath.addUnitVector(location, i))
        end
	return points
end

function StructureMath.addDirectionVector(vector, direction, scale)
	return {vector[1] + unitVectors[direction][1] * scale,
			vector[2] + unitVectors[direction][2] * scale,
			vector[3]}
end

local multipliers = {{1, 1}, {-1, 1}, {-1, -1},{1, -1}}
local swap = {false, true, false, true}
function StructureMath.rotateVector(vector, rotation)
	if swap[rotation] then
		vector = {vector[2], vector[1]}
	end
	local mult = multipliers[rotation]
	vector = {mult[1] * vector[1],
			  mult[2] * vector[2]}
	return vector
end

function StructureMath.sumVectors(vectorA, vectorB)
	local rotation = StructureMath.toDirection(vectorA[3] + vectorB[3])
	local vector = StructureMath.rotateVector(vectorB, vectorA[3])
	vector[1] = vectorA[1] + vector[1]
	vector[2] = vectorA[2] + vector[2]
	vector[3] = rotation
	return vector
end

function StructureMath.subtractVectors(vectorA, vectorB)
	local rotation = StructureMath.toDirection(vectorA[3] - vectorB[3])
	local vector = StructureMath.rotateVector(vectorB, rotation)
	vector[1] = vectorA[1] - vector[1]
	vector[2] = vectorA[2] - vector[2]
	vector[3] = rotation
	return vector
end
--[[
function StructureMath.precalcAnnex(structureVector, annexeeVector)
	local baseVector
	--return
end
--]]

function StructureMath.getPartSide(structure, partLocation, cursorX, cursorY)
	local cursorX, cursorY = structure.body:getLocalPoint(cursorX, cursorY)
	local netX , netY = cursorX - partLocation[1], cursorY - partLocation[2]
	local netXSq, netYSq = netX * netX, netY * netY

	local a = netXSq > netYSq and 1 or 0
	local b = netY - netX < 0 and 2 or 0
	return 1 + a + b, netXSq <= .25 and netYSq <= .25
end

return StructureMath

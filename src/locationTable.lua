local vector = require("vector")


print(debug.traceback("Using Deprecated LocationTable"))

local LocationTable = class()

function LocationTable:__create(...)
	local input = {...}
	local lead = input[1]
	local t
	local typeString = type(lead)
	if typeString == "userdata" then
		typeString = lead.type and lead:type()
	end


	if typeString == "nil" then
		t = {}
	elseif typeString == "number" then
		t = input
	elseif typeString == "string" then
		print(debug.traceback("Using Deprecated Functionality"))
		t = {}
		for coord in string.gmatch(lead, "[%w]-([-%d.e]*)[%w]-[,]-") do
			table.insert(t, tonumber(coord))
		end
	elseif typeString == "Body" then
		--print(debug.traceback("Using Deprecated Functionality"))
		t = {}
		t[1], t[2] = lead:getPosition()
		t[3] = lead:getAngle()
		t[4], t[5] = lead:getLinearVelocity()
		t[6] = lead:getAngularVelocity()
	elseif typeString == "Fixture" then
		print(debug.traceback("Using Deprecated Functionality"))
		local body = lead:getBody()
		local l = input[2]
		if body and l then
			local partX, partY, angle = unpack(l)
			local x, y = body:getWorldPoints(partX, partY)
			angle = (angle - 1) * math.pi/2 + body:getAngle()
			local vx, vy = body:getLinearVelocityFromLocalPoint(partX, partY)
			local w = body:getAngularVelocity()
			t = {x, y, angle, vx, vy, w}
		end
	end

	if not t then
		error("first argument is an invalid type", 3)
	end

	for i = 1,6 do
		if not t[i] then t[i] = 0 end
		self[i] = t[i]
	end
end

function LocationTable:__tostring()
	print(debug.traceback("Using Deprecated Functionality"))
	local string = ""
	for i in ipairs(self) do
		if not (i == 1) then string = string .. ","	end
		string = string .. tostring(self[i])
	end
	return string
end
--[[
function LocationTable:__add(locationTable)
	print(debug.traceback("Using Deprecated Functionality"))
	local l = LocationTable(unpack(locationTable))

	l[1], l[2] = vector.rotate(l[1], l[2], self[3])
	l[4], l[5] = vector.rotate(l[4], l[5], self[3])

	for i = 1, 6 do
		l[i] = l[i] + self[i]
	end

	return l
end
--]]
--[[
function LocationTable:setX(x) self[1] = x end
function LocationTable:setY(y) self[2] = y end
function LocationTable:setA(a) self[3] = a end
function LocationTable:setVX(vx) self[4] = vx end
function LocationTable:setVY(vy) self[5] = vy end
function LocationTable:setW(w) self[6] = w end
function LocationTable:setXY(x, y) self[1] = x; self[2] = y end
function LocationTable:setXYA(x, y, a) self[1] = x; self[2] = y; self[3] = a end
function LocationTable:setV(vx, vy) self[4] = vx; self[5] = vy end
function LocationTable:setVW(vx, vy, w) self[4] = vx; self[5] = vy; self[6] = w end
--]]

--[[
function LocationTable:getX()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[1]
end
function LocationTable:getY()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[2]
end
function LocationTable:getA()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[3]
end
function LocationTable:getVX()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[4]
end
function LocationTable:getVY()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[5]
end
function LocationTable:getW()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[6]
end
function LocationTable:getXY()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[1], self[2]
end
function LocationTable:getXYA()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[1], self[2], self[3]
end
function LocationTable:getV()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[4], self[5]
end
function LocationTable:getVW()
	print(debug.traceback("Using Deprecated Functionality"))
	return self[4], self[5], self[6]
end
function LocationTable:getAll()
	print(debug.traceback("Using Deprecated Functionality"))
	return unpack(self)
end
--]]
return LocationTable

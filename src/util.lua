-- The Util module is a namespace for the various mathematical functions that we
-- need.

local Util = {}

function Util.vectorMagnitude(x, y)
	local r = math.sqrt(x^2 + y^2)
	return r
end

function Util.vectorAngle(x, y)
	local t = math.atan2(y, x)
	return t
end

function Util.vectorComponents(r, angle)
	local x = r * math.cos(angle)
	local y = r * math.sin(angle)
	return x, y
end

function Util.computeAbsCoords(x, y, angle)
	local r = Util.vectorMagnitude(x, y)
	local t = Util.vectorAngle(x, y)
	return Util.vectorComponents(r, t + angle)
end

function Util.sign(x)
   if x<0 then
	   return -1
   elseif x>0 then
	   return 1
   else
	   return 0
   end
end

function Util.absVal(x)
	if x < 0 then
		x = -x
	end
	return x
end

function Util.packLocation(input)
	local location = {}
	if input.body then
		location[1] = input.body:getX()
		location[2] = input.body:getY()
		location[3] = input.body:getAngle()
		location[4], location[5] = input.body:getLinearVelocity()
		location[6] = input.body:getAngularVelocity()
	else
		location = input
	end
	local locationString = "("
	for i in ipairs(location) do
		if not (i == 1) then locationString = locationString .. ","	end
		locationString = locationString .. tostring(location[i])
	end
	locationString = locationString .. ")"
	return locationString
end

function Util.unpackLocation()
end

function Util.packData(data)
	local dataString = "["
	for i in ipairs(data) do
		if not (i == 1) then dataString = dataString .. ","	end
		dataString = dataString .. tostring(data[i])
	end
	dataString = dataString .. "]"
	return dataString
end

function Util.unpackLocation()
end

return Util

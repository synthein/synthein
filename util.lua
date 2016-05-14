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

function Util.max(a, b)
	if a > b then
		return a
	else
		return b
	end
end

function Util.min(a,b)
	if a < b then
		return a
	else
		return b
	end
end

return Util

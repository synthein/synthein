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



return Util

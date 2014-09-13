function vectorMagnitude(x, y)
	local r = math.sqrt(x^2 + y^2)
	return r
end

function vectorAngle(x, y)
	local t = math.atan2(y, x)
	return t
end

function vectorComponents(r, t, angle)
	local x = r * math.cos(angle + t)
	local y = r * math.sin(angle + t)
	return x, y
end

function computeAbsCoords(x, y, angle)
	local r = vectorMagnitude(x, y)
	local t = vectorAngle(x, y)
	return vectorComponents(r, t, angle)
end

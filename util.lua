function vectorMagnitude(x, y)
	r = math.sqrt(x^2 + y^2)
	return r
end

function vectorAngle(x, y)
	t = math.atan2(y, x)
	return t
end

function vectorComponents(r, t, angle)
	local x = r * math.cos(angle + t)
	local y = r * math.sin(angle + t)
	return x, y
end

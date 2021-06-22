local vector = {}

function vector.sign(x)
	if x<0 then
		return -1
	elseif x>0 then
		return 1
	else
		return 0
	end
end

function vector.magnitude(x, y)
	local r = math.sqrt(x^2 + y^2)
	return r
end

function vector.angle(x, y)
	local t = math.atan2(y, x)
	return t
end

function vector.components(r, angle)
	local x = r * math.cos(angle)
	local y = r * math.sin(angle)
	return x, y
end

function vector.rotate(x, y, angle)
	local r = vector.magnitude(x, y)
	local t = vector.angle(x, y)
	return vector.components(r, t + angle)
end

return vector

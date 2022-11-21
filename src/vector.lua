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

function vector.add(a, b)
	local l = {}
	l[1], l[2] = vector.rotate(b[1], b[2], a[3])
	l[3] = b[3]
	l[4], l[5] = vector.rotate(b[4] or 0, b[5] or 0, a[3])
	l[6] = b[6] or 0

	for i = 1, 6 do
		l[i] = l[i] + a[i]
	end

	return l
end

return vector

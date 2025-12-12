local parse = {}

function parse.parseNumbers(string)
	local t = {}
	for coord in string.gmatch(string, "[-0-9.e]+") do
		table.insert(t, tonumber(coord))
	end
	return t
end

function parse.packLocation(input)
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

function parse.packData(data)
	local dataString = "["
	for i in ipairs(data) do
		if not (i == 1) then dataString = dataString .. ","	end
		dataString = dataString .. tostring(data[i])
	end
	dataString = dataString .. "]"
	return dataString
end

return parse

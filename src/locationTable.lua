local LocationTable = class()

function LocationTable:__create(...)
	local input = {...}
	local lead = input[1]
	local t
	local typeString = type(lead)
	if typeString == "nil" then
		t = {}
	elseif typeString == "number" then
		t = input
	elseif typeString == "string" then
		local l = {}
		for coord in string.gmatch(locationString, "([])[%w]-[-%d.e]*[%w]-") do
			table.insert(l, tonumber(coord))
		end
		print("location from string:")
		for i = 1,6 do
			print(t[i])
		end
	elseif typeString == "body" then
		t = {
			lead:getPosition(),
			lead:getAngle(),
			lead:getLinearVelocity(),
			lead:getAngularVelocity(),
		}
		-- Debug
		print("location from body:")
		for i = 1,6 do
			print(t[i])
		end
	end

	for i = 1,6 do
		if not t[i] then t[i] = 0 end
		self[i] = t[i]
	end
end

function LocationTable:__tostring()
	local string = ""
	for i in ipairs(self) do
		if not (i == 1) then string = string .. ","	end
		string = string .. tostring(self[i])
	end
	return string
end

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

function LocationTable:getX() return self[1] end
function LocationTable:getY() return self[2] end
function LocationTable:getA() return self[3] end
function LocationTable:getVX() return self[4] end
function LocationTable:getVY() return self[5] end
function LocationTable:getW() return self[6] end
function LocationTable:getXY() return self[1], self[2] end
function LocationTable:getXYA() return self[1], self[2], self[3] end
function LocationTable:getV() return self[4], self[5] end
function LocationTable:getVW() return self[4], self[5], self[6] end
function LocationTable:getAll() return unpack(self) end

function LocationTable:createBody(physics, mode)
	local body = love.physics.newBody(physics, self[1], self[2], mode)
	body:setAngle(self[3])
	body:setLinearVelocity(self[4], self[5])
	body:setAngularVelocity(self[6])
	return body
end

return LocationTable

local Location = {}

function Location.bodyCenter3(body)
	local x, y = body:getPosition()
	local a = body:getAngle()
	return x, y, a
end

function Location.bodyCenter6(body)
	local x, y = body:getPosition()
	local a = body:getAngle()
	local vx, vy = body:getLinearVelocity()
	local w = body:getAngularVelocity()
	return x, y, a, vx, vy, w
end

function Location.bodyPoint3(body, px, py)
	local x, y = body:getWorldPoints(px, py)
	local a = body:getAngle()
	return x, y, a
end

function Location.bodyPoint6(body, px, py)
	local x, y = body:getWorldPoints(px, py)
	local a = body:getAngle()
	local vx, vy = body:getLinearVelocityFromLocalPoint(px, py)
	local w = body:getAngularVelocity()
	return x, y, a, vx, vy, w
end

function Location.fixtureCenter3(fixture)
	local body = fixture:getBody()
	return Location.bodyCenter3(body)
end

function Location.fixtureCenter6(fixture)
	local body = fixture:getBody()
	return Location.bodyCenter6(body)
end

function Location.fixturePoint3(fixture, px, py)
	local body = fixture:getBody()
	return Location.bodyPoint3(body, px, py)
end

function Location.fixturePoint6(fixture, px, py)
	local body = fixture:getBody()
	return Location.bodyPoint6(body, px, py)
end

return Location

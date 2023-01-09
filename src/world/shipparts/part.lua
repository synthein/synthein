local Part = class()

function Part:__create()
	self.connectableSides = {true, true, true, true}
	self.modules = {}
	self.type = "generic"
end

function Part:loadData(data)
	if data[1] then self.modules.hull.health = data[1] end
end

function Part:saveData()
	return {self.modules.hull.health}
end

function Part:addFixtures(body)
	self.modules["hull"]:addFixtures(body)
end

function Part:removeFixtures()
	self.modules["hull"]:removeFixtures()
end

function Part:setLocation(location)
	self.location = location
	self.modules["hull"].userData.location = location
end

function Part:withinPart(x, y)
	return self.modules["hull"].fixture:testPoint(x, y)
end

return Part

local Anchor = class(require("world/shipparts/part"))

function Anchor:__create()
	self.image = "anchor"
	self.width, self.height = 1, 1

	self.type = "anchor"
	self.team = 1

	return self
end

function Anchor:getTeam()
	return self.team
end

function Anchor:getOrders()
	return {}
end

return Anchor

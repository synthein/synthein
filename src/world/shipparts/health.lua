local Health = class()

function Health:__create(startValue)
	self.health = startValue
	self.maxHealth = startValue
	self.isDestroyed = false
end

function Health:repair(repair)
	self.health = self.health + repair
end

function Health:damage(damage, location)
	self.health = self.health - damage
	if self.health <= 0 then
		self.isDestroyed = true
		self.location = location
	end
end

function Health:update(disconnectCallback, createCallback)
	if self.isDestroyed then
		disconnectCallback(true)
		createCallback({"particles", self.location})
	end
end

return Health

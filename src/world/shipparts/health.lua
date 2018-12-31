local Health = class()

function Health:__create(startValue)
	self.health = startValue
	self.maxHealth = startValue
	self.isDestroyed = false
end

function Health:getIsDestroyed()
	return function() return self.isDestroyed end
end

function Health:repair(repair)
	self.health = self.health + repair
end

function Health:damage(damage)
	self.health = self.health - damage
	if self.health <= 0 then self.isDestroyed = true end
	return self.isDestroyed
end

return Health

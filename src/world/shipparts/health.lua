local Health = class()

function Health:__create(startValue)
	self.health = startValue
	self.maxHealth = startValue
	self.isDestroyed = false
end

function Health:getScaledHealh()
	return self.health / self.maxHealth
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

function Health:update()
	if self.isDestroyed then
		return {"particles", {0, 0, 1}}, true
	end
end

return Health

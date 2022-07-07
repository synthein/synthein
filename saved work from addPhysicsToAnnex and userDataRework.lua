-- annex.lua

Annex = class()

function Annex:__create(team)
	self.stage = 0
	self.abort = false
	self.team = team


	local structureHandle = {}
	function structureHandle.Abort()
		self.abort
end

function Annex:abort()
	self.abort = true
end

function Annex:getRequest()
	local stage = self.stage
	if     stage == 0 then
		-- check for part and connectableSides
	elseif stage == 1 then
	elseif stage == 2 then
	elseif stage == 3 then
	elseif stage == 4 then
	elseif stage ==


end

return Annex

-- structure.lua

function Structure:update(dt)
print(self.isDestroyed)
	local partsInfo = self:command(dt)
	self.shield:update(dt)

	if self.annexBundle then
		if self.corePart then
			if self.annexBundle.parts then
				self:annex(self.annexBundle.parts, unpack(self.annexBundle.inputs))
				self.annexBundle = nil
			end
			self.annexBundle.goalA = {self.body:getPosition()}
			if self.annexBundle.goalS then
				local a = self.annexBundle.goalA
				local s = self.annexBundle.goalS
				local dx = s[1] - a[1]
				local dy = s[2] - a[2]
				self.body:applyForce(dx, dy)
			end
		else
			self.annexBundle.goalS = {self.body:getPosition()}
			if self.annexBundle.goalA then
				local a = self.annexBundle.goalA
				local s = self.annexBundle.goalS
				local dx = a[1] - s[1]
				local dy = a[2] - s[2]
				self.body:applyForce(dx, dy)

				if false then
					self.annexBundle.parts = self.gridTable:loop()
					for _, part in ipairs(self.annexBundle.parts) do
						self:removePart(part)
					end
					self.annexBundle = nil
				end
			end
		end
	end
end

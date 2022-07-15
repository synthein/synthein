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

-- annexRequest.lua

 local Annex = class()

function Annex:__create(
		bodyUserData, partLocation,
		annexeeBodyUserData, nnexeePartLocation)

	self.denied = false
	self.replied = false
	self.partLocation = partLocation
	self.annexeePartLocation = annexeePartLocation



end

function Annex:deny()
	self.denied = true
end

function Annex:isDenied()
	return self.denied
end

function Annex:hasReplied()
	return self.replied
end

function Annex:getLocations()
	return partLocation, annexeePartLocation
end

function Annex:getRequest()
	local function f(structure)
		self.replied = true
		self.annexee = structure
		return true
	 end
	 return f
end

function Annex:getAtempt()
	local function f(structure)
		if self.annexee then return false end
		structure:annex(
			self.annexee, self.annexeePart,
			self.annexeePartSide,
			self.structurePart, self.structurePartSide)
		return true
end

return Annex

-- structure.lua

 function Structure:update(dt)
	local userData = self.body:getUserData()
	local buildRequest = userData.buildRequest
	if buildRequest then
		local team = userData.getTeam()
		if buildRequest.type == 1 then
			if team == buildRequest.team or team == 0 then
				userData.buildRequest = nil
				if buildRequest.disconnect then
					self:disconnectPart(buildRequest.aPart, false)
				else
					self:annex(
						buildRequest.b, buildRequest.bPart, buildRequest.bSide,
						buildRequest.aPart, buildRequest.aSide)
				end
			end
		elseif buildRequest.type == 2 then
			if team == 0 then
				userData.buildRequest = nil
				buildRequest.b = self
			end
		end
	end

	local partsInfo = self:command(dt)
	self.shield:update(dt)
end

-- beginning of Selection:pressed()

		-- build request disconnect
		if not structure.buildRequest then
			local buildRequest = {}
			buildRequest.type = 1
			buildRequest.disconnect = true
			buildRequest.team = self.team
			buildRequest.aPart = {roundedX, roundedY}

			structure.buildRequest = buildRequest
		end

	-- Selection.lua
	local function getpartSide(body, partLocation, cursorX, cursorY)
		local cursorX, cursorY = body:getLocalPoint(cursorX, cursorY)
		local netX , netY = cursorX - partLocation[1], cursorY - partLocation[2]
		local netXSq, netYSq = netX * netX, netY * netY

		local a, b = 0, 0
		if netXSq > netYSq then a = 1 end
		if netY - netX < 0 then b = 2 end
		return 1 + a + b, netXSq <= .25 and netYSq <= .25
	end

-- Beginning of Selection:released()
		local l = self.part.location
		local partSide, withinPart = getpartSide(body, l, cursorX, cursorY)
		local x, y = body:getWorldPoints(l[1], l[2])

-- Beginning of Selection:draw()
		local x, y = body:getWorldPoints(l[1], l[2])
		local angle = (l[3] - 1) * math.pi/2 + body:getAngle()
		local partSide = getpartSide(body, l, cursorX, cursorY)

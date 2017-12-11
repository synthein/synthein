local Menu = {}
Menu.__index = Menu

Menu.scrollSpeed = 150

function Menu.create(x, y, size, buttons, camera)
	self = {}
	setmetatable(self, Menu)

	self.x = x
	self.y = y
	self.width = size * 100
	self.buttonWidth = size * 90
	self.buttonHeight = size * 10
	self.buttonSpacing = size * 5
	self.buttonMargin = (self.width - self.buttonWidth) / 2
	self.textHeight = size * 8
	self.buttons = buttons
	self.scrollY = 0
	self.scrollVelocity = 0
	self.selectedButton = nil
	self.camera = camera
	if love.graphics then self.font = love.graphics.newFont(size * 7) end
	if love.graphics then self.visibleHeight = love.graphics.getHeight() - self.y - self.buttonMargin end

	return self
end

function Menu:getButtonAt(x, y)
	if x > self.x - self.width / 2 + self.buttonMargin
	   and x < self.x + self.buttonMargin + self.buttonWidth
	   and y > self.y then
		local yRef = y - self.y - self.buttonMargin + self.scrollY
		local index = math.floor(yRef/(self.buttonHeight + self.buttonSpacing)) + 1
		local remainder = yRef % (self.buttonHeight + self.buttonSpacing)
		if index > 0 and index <= #self.buttons and
		   remainder < self.buttonHeight then
			return index
		end
	end
	return nil
end

function Menu:getHeight()
	return self.buttonMargin * 2
	       + #self.buttons * self.buttonHeight
	       + (#self.buttons - 1) * self.buttonSpacing
end

function Menu:update(dt)
	self.scrollY = self.scrollY + self.scrollVelocity * dt
	self.scrollVelocity = self.scrollVelocity * 0.98

	local menuHeight = self:getHeight()
	if self.visibleHeight and menuHeight > self.visibleHeight then
		-- Reset scroll position and velocity if we hit the top or bottom of
		-- the menu.
		-- Top of the menu:
		if self.scrollY < 0 then
			self.scrollY = 0
			if self.scrollVelocity < 0 then
				self.scrollVelocity = 0
			end
		end

		-- Bottom of the menu:
		if self.scrollY > menuHeight - self.visibleHeight then
			self.scrollY = menuHeight - self.visibleHeight
			if self.scrollVelocity > menuHeight then
				self.scrollVelocity = 0
			end
		end

		-- Scroll toward the selected button if it is off the screen.
		if self.selectedButton then
			local buttonTopY = self.y + (self.buttonHeight + self.buttonSpacing) * (self.selectedButton - 1) - self.scrollY
			local buttonBottomY = self.y + (self.buttonHeight + self.buttonSpacing) * (self.selectedButton - 1) + self.buttonHeight - self.scrollY

			if buttonTopY < self.y then
				self.scrollVelocity = -self.scrollSpeed
			elseif buttonBottomY > self.y + self.visibleHeight then
				self.scrollVelocity = self.scrollSpeed
			end
		end
	end
end

function Menu:draw()
	love.graphics.push("all")
	local x, y
	if self.camera then
		x, y = self.camera:getScissor()
		x = x + self.x - self.width / 2
		y = y + self.y
	else
		x = self.x - self.width / 2
		y = self.y
	end

	love.graphics.setScissor(x, y, self.width, self.visibleHeight)
	love.graphics.setColor(200, 200, 200)
	love.graphics.rectangle(
		"fill",
		x, y,
		self.width, math.min(self:getHeight(), self.visibleHeight))

	for i, button in ipairs(self.buttons) do
		if i == self.selectedButton then
			love.graphics.setColor(150, 150, 150)
		else
			love.graphics.setColor(100, 100, 100)
		end
		
		love.graphics.rectangle(
			"fill",
			x + self.buttonMargin,
			y + self.buttonMargin + self.buttonHeight * (i - 1) + self.buttonSpacing * (i - 1) - self.scrollY,
			self.buttonWidth, self.buttonHeight
		)
		love.graphics.setColor(255, 255, 255)
		local previousFont = love.graphics.getFont()
		love.graphics.setFont(self.font)
		love.graphics.print(
			self.buttons[i],
			x + self.buttonMargin + 10,
			y + self.buttonMargin + self.buttonHeight * (i - 1) + self.buttonSpacing * (i - 1) + (self.buttonHeight - self.textHeight)/2 - self.scrollY,
			0, 1, 1, 0, 0, 0, 0
		)
		love.graphics.setFont(previousFont)
	end

	love.graphics.pop()
end

function Menu:resize(w, h)
	self.visibleHeight = h - self.y
end

function Menu:keypressed(key)
	if key == "up" then
		if self.selectedButton > 1 then
			self.selectedButton = self.selectedButton - 1
		end
	elseif key == "down" then
		if self.selectedButton < #self.buttons then
			self.selectedButton = self.selectedButton + 1
		end
	elseif key == "return" then
		return self.buttons[self.selectedButton]
	end
end

function Menu:mousemoved(x, y)
	index = self:getButtonAt(x, y)
	if index == nil then
		return
	end
	self.selectedButton = index
end

function Menu:wheelmoved(x, y)
	self.selectedButton = nil
	if self:getHeight() > self.visibleHeight then
		if y < 0 then
			self.scrollVelocity = self.scrollSpeed
		elseif y > 0 then
			self.scrollVelocity = -self.scrollSpeed
		end
	end
end

function Menu:pressed(x, y)
	index = self:getButtonAt(x, y)
	if index == nil then
		return nil
	end
	return self.buttons[index]
end

return Menu

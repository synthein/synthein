local Menu = {}
Menu.__index = Menu

Menu.scrollSpeed = 150

function Menu.create(x, y, size, buttons, camera)
	self = {}
	setmetatable(self, Menu)

	self.buttonWidth = size * 100
	self.buttonHeight = size * 10
	self.buttonSpacing = size * 15
	self.textHeight = size * 8
	self.x = x - self.buttonWidth/2
	self.y = y
	self.buttons = buttons
	self.scrollY = 0
	self.scrollVelocity = 0
	self.selectedButton = 0
	self.camera = camera
	if love.graphics then self.font = love.graphics.newFont(size * 7) end

	return self
end

function Menu:getButtonAt(x, y)
	if x > self.x and x < self.x + self.buttonWidth and y > self.y then
		local yRef = y - self.y + self.scrollY
		local index = math.floor(yRef/self.buttonSpacing) + 1
		local remainder = yRef % self.buttonSpacing
		if index > 0 and index <= #self.buttons and
		   remainder < self.buttonSpacing then
			return index
		end
	end
	return nil
end

function Menu:getHeight()
	return #self.buttons * self.buttonSpacing
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
		local buttonTopY = self.y + self.buttonSpacing * (self.selectedButton - 1) - self.scrollY
		local buttonBottomY = self.y + self.buttonSpacing * (self.selectedButton - 1) + self.buttonHeight - self.scrollY

		if buttonTopY < self.y then
			self.scrollVelocity = -self.scrollSpeed
		elseif buttonBottomY > self.y + self.visibleHeight then
			self.scrollVelocity = self.scrollSpeed
		end
	end
end

function Menu:draw()
	self.visibleHeight = love.graphics.getHeight() - self.y
	local x, y
	if self.camera then
		love.graphics.setScissor(self.camera:getScissor())
		x, y = self.camera:getScissor()
		x = x + self.x
		y = y + self.y
	else
		x = self.x
		y = self.y
	end

	for i, button in ipairs(self.buttons) do
		if i == self.selectedButton then
			love.graphics.setColor(180, 180, 180)
		else
			love.graphics.setColor(100, 100, 100)
		end
		
		love.graphics.rectangle(
			"fill",
			self.x,
			self.y + self.buttonSpacing * (i - 1) - self.scrollY,
			self.buttonWidth, self.buttonHeight
		)
		love.graphics.setColor(255, 255, 255)
		local previousFont = love.graphics.getFont()
		love.graphics.setFont(self.font)
		love.graphics.print(
			self.buttons[i],
			self.x + 10,
			self.y + 75 * (i - 1) + (self.buttonHeight - self.textHeight)/2 - self.scrollY,
			0, 1, 1, 0, 0, 0, 0
		)
		love.graphics.setFont(previousFont)
	end
	
	if self.camera then
		love.graphics.setScissor()
	end
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

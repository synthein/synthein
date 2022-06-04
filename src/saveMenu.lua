local SaveMenu = class()

-- Make a menu in the center of the screen from a list of buttons.
function SaveMenu:__create()

	self.y = 250
	self.width = 100
	self.height = 40


	--if love.graphics then self.font = love.graphics.newFont(size * 7) end
	--if love.graphics then self.visibleHeight = love.graphics.getHeight() - self.y - self.buttonMargin end

	return self
end

function SaveMenu:getButtonAt(x, y)
	local menuCenter = love.graphics.getWidth() / 2
	if x > menuCenter - self.buttonWidth / 2
	   and x < menuCenter + self.buttonWidth / 2
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

function SaveMenu:draw()
	love.graphics.push("all")
	local x = love.graphics.getWidth() / 2 - self.width / 2
	local y = self.y

	love.graphics.setColor(0.8, 0.8, 0.8)
	love.graphics.rectangle("fill", x, y, self.width, self.height)


	--love.graphics.setColor(0.6, 0.6, 0.6)
	love.graphics.setColor(0.4, 0.4, 0.4)
	love.graphics.rectangle("fill", x+5, y+5, self.width-10, self.height-10)

	love.graphics.pop()
end

function SaveMenu:keypressed(key)
	-- Add main text modifing code here
end

function SaveMenu:mousemoved(x, y)
	--TODO check if this function is useful for the cursor
end

function SaveMenu:pressed(x, y)
	--TODO implement a cursor and modifiable text
end

return SaveMenu

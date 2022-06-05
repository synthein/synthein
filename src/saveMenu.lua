local SaveMenu = class()

-- Make a menu in the center of the screen from a list of buttons.
function SaveMenu:__create()

	self.y = 250
	self.width = 200
	self.height = 60

	self.saveName = "filename"

	--if love.graphics then self.font = love.graphics.newFont(size * 7) end
	--if love.graphics then self.visibleHeight = love.graphics.getHeight() - self.y - self.buttonMargin end

	return self
end

function getFileString()
	return saveName
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


	love.graphics.setColor(0, 0, 0)
	--love.graphics.print("Type a name to use for your save, then press enter:", screen_width/2-150, 60)
	love.graphics.print(self.saveName, x+10, y+10)

	love.graphics.pop()
end

function SaveMenu:keypressed(key)
	-- Add main text modifing code here

	if key == "backspace" then
		-- The string is utf-8 encoded, so the last character of the string
		-- could be multiple bytes.
		local byteoffset = utf8.offset(saveName, -1)
		if byteoffset then
			saveName = saveName:sub(1, byteoffset - 1)
		end
	elseif key == "return" then
		typingSaveName = false
	elseif key == "escape" then
		saveName = ""
		typingSaveName = false
	end
end

function SaveMenu:mousemoved(x, y)
	--TODO check if this function is useful for the cursor
end

function SaveMenu:pressed(x, y)
	--TODO implement a cursor and modifiable text
end

return SaveMenu

local utf8 = require("utf8")

local TextBox = class()

-- Make a menu in the center of the screen from a list of buttons.
function TextBox:__create(x, y, width, height, startText)

	self.y = 250
	self.width = 300
	self.height = 60

	self.text = startText or ""
	
	self.validCharacters = "^%w$"

	--TODO custom font
	
	--TODO cursor starting location

	return self
end

function TextBox:draw()
	--TODO refresh Draw Function
	--TODO Draw Cursor
	
	love.graphics.push("all")
	local x = love.graphics.getWidth() / 2 - self.width / 2
	local y = self.y

	love.graphics.setColor(0.8, 0.8, 0.8)
	love.graphics.rectangle("fill", x, y, self.width, self.height)


	--love.graphics.setColor(0.6, 0.6, 0.6)
	love.graphics.setColor(0.4, 0.4, 0.4)
	love.graphics.rectangle("fill", x+5, y+5, self.width-10, self.height-10)


	love.graphics.setFont(love.graphics.newFont(30))
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(self.text, x+10, y+10)

	love.graphics.pop()
end

function TextBox:keyInput(key)
	--Not sure how non acii characters come in.
	
	--TODO add cursor 

	if key == "backspace" then
		-- The string is utf-8 encoded, so the last character of the string
		-- could be multiple bytes.
		local byteoffset = utf8.offset(self.text, -1)
		if byteoffset then
			self.text =self.text:sub(1, byteoffset - 1)
		end
	elseif key:match(self.validCharacters) then
		self.text = self.text .. key
	end
end

function TextBox:mousemoved(x, y)
	--TODO check if this function is useful for the cursor
end

function TextBox:pressed(x, y)
	--TODO implement a cursor and modifiable text
end

return TextBox

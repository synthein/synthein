local utf8 = require("utf8")
local TextBox = require("widgets/textBox")

local SaveMenu = class()

-- Make a menu in the center of the screen from a list of buttons.
function SaveMenu:__create(dir, currentName)
	self.dir = dir
	currentName = currentName or "filename"
	self.currentName = currentName
	
	self.textBox = TextBox(love.graphics.getWidth() / 2 - 60 / 2, 250, 300, 60, currentName)

	return self
end

function SaveMenu:resetName()
	self.textBox.text = self.currentName
end

-- Returns boolean success status and (optionally) a message explaining why
-- there was a failure.
function SaveMenu:saveFile(fileContents)
	local saveDir = self.dir
	local saveName = self.textBox.text
	local filename = saveDir .. saveName .. ".txt"

	if not love.filesystem.getInfo(saveDir, "directory") then
		local ok = love.filesystem.createDirectory(saveDir)
		if not ok then
			return false, "failed to create save directory"
		end
	end

	self.currentName = saveName

	return love.filesystem.write(filename, fileContents)
end

function SaveMenu:draw()
	self.textBox:draw()
end

function SaveMenu:keypressed(key)
	-- Add main text modifing code here

	if key == "backspace" then
		self.textBox:keyInput(key)
	end
end

function SaveMenu:textinput(key)
	self.textBox:keyInput(key)
end

function SaveMenu:mousemoved(x, y)
	--TODO check if this function is useful for the cursor
end

function SaveMenu:pressed(x, y)
	--TODO implement a cursor and modifiable text
end

return SaveMenu

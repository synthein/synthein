local Camera = require("camera")

local Screen = class()

function Screen:__create()
	self.cameras = {}
end

function Screen:createCamera()
	local newCamera = Camera.create()
	table.insert(self.cameras, newCamera)
	self:arrange(love.graphics.getWidth(), love.graphics.getHeight())
	return newCamera
end

function Screen:arrange(screenWidth, screenHeight)
	local n = #self.cameras
	local columns, rows = 1, 1
	for i = 1, n do
		if i > columns * rows then
			if screenWidth / columns > screenHeight / rows then
				columns = columns + 1
			else
				rows = rows + 1
			end
		end
	end

	if columns > rows then
		columns = math.min(columns, math.ceil(n / rows))
	else
		rows = math.min(rows, math.ceil(n / columns))
	end

	local cameraWidth  = math.floor(screenWidth/columns)
	local cameraHeight = math.floor(screenHeight/rows)
	for i, camera in ipairs(self.cameras) do
		local x = (i-1)%columns
		local y = (i-x -1)/columns
		camera:setScissor(x*cameraWidth, y*cameraHeight,
						  cameraWidth, cameraHeight)
	end
end

return Screen

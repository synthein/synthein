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

function Screen:clearCameras()
	self.cameras = {}
end

function Screen:arrange(screenWidth, screenHeight)
	local n = #self.cameras
	local screenArea = screenWidth * screenHeight
	local cameraArea = screenArea / n
	local columns = math.ceil(screenWidth/math.sqrt(cameraArea)-0.5)
	local rows = math.ceil(n/columns)
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

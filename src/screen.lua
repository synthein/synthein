local Camera = require("camera")

local Screen = {}
Screen.__index = Screen

Screen.cameras = {}

function Screen.createCamera()
	newCamera = Camera.create()
	table.insert(Screen.cameras, newCamera)
	Screen.arrange()
	return newCamera
end

function Screen.arrange()
	local n = #Screen.cameras
	local screenWidth = love.graphics.getWidth()
	local screenHeight = love.graphics.getHeight()
	local screenArea = screenWidth * screenHeight
	local cameraArea = screenArea / n
	local columns = math.ceil(screenWidth/math.sqrt(cameraArea)-0.5)
	local rows = math.ceil(n/columns)
	local cameraWidth  = math.floor(screenWidth/columns)
	local cameraHeight = math.floor(screenHeight/rows)
	for i, camera in ipairs(Screen.cameras) do
		local x = (i-1)%columns
		local y = (i-x -1)/columns
		camera:setScissor(x*cameraWidth, y*cameraHeight,
						  cameraWidth, cameraHeight)
	end
end

return Screen

local Camera = require("camera")

local Screen = {}
Screen.__index = Screen

function Screen.createCamera()
	newCamera = Camera.create()
	newCamera:setX(0)
	newCamera:setY(0)
	Screen.camera = newCamera
	Screen.arrange()
	return newCamera
end

function Screen.arrange()
	--local n = Screen.cameras
	n = 1
	local screenArea = SCREEN_WIDTH * SCREEN_HEIGHT
	local cameraArea = screenArea / n
	local columns = math.ceil(SCREEN_WIDTH/math.sqrt(cameraArea)-0.5)
	local rows = math.ceil(n/columns)
	local cameraWidth  = math.floor(SCREEN_WIDTH/columns)
	local cameraHeight = math.floor(SCREEN_HEIGHT/rows)
	--Screen.camera:setScissor(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
	Screen.camera:setScissor(0, 0, cameraWidth, cameraHeight)
end

function Screen.setCameras(numberOfCameras)
	Screen.cameras = numberOfCameras
end

function Screen.setCamera(currentCamera)
	Screen.camera = currentCamera
end

function Screen.getCursorCoords(X, Y)
	return Screen.camera:getCursorCoords(X, Y)
end

function Screen.draw(image, x, y, angle, sx, sy, ox, oy)
	Screen.camera:draw(image, x, y, angle, sx, sy, ox, oy)
end

function Screen.drawExtras()
	Screen.camera:drawExtras()
end

return Screen

local Camera = require("camera")

local Screen = {}
Screen.__index = Screen

function Screen.createCamera()
	newCamera = Camera.create()
	newCamera:setX(0)
	newCamera:setY(0)
	Screen.camera = newCamera
	return newCamera
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

function Screen.draw(image, x, y , angle, sx, sy, ox, oy)
	Screen.camera:draw(image,
					   x,
					   y,
					   angle, sx, sy, ox, oy)
end

function Screen.drawCanvas()
	Screen.camera:drawExtras()
end

return Screen

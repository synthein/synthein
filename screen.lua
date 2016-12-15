local Camera = require("camera")

local Screen = {}
Screen.__index = Screen

function Screen.createCameras()
	Screen.camera = Camera.create()
	Screen.camera:setX(0)
	Screen.camera:setY(0)
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

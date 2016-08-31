local Camera = require("camera")

local Screen = {}
Screen.__index = Screen

Screen.camera = Camera.create()

function Screen:setCameras(numberOfCameras)
	Screen.cameras = numberOfCameras
end

function Screen:setCamera(currentCamera)
	Screen.camera = currentCamera
end

function Screen.getCursorCoords(X, Y)
	cursorCoordX =   X - SCREEN_WIDTH /2  + Screen.camera.getX()
	cursorCoordY = -(Y - SCREEN_HEIGHT/2) + Screen.camera.getY()
	return cursorCoordX, cursorCoordY
end
function Screen.draw(image, x,y, angle, sx, sy, ox, oy)
	Screen.camera:draw(image, x,y, angle, sx, sy, ox, oy)
end

return Screen

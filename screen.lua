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

function Screen.draw(image, x,y, angle, sx, sy, ox, oy)
	Screen.camera:draw(image, x,y, angle, sx, sy, ox, oy)
end

return Screen

local LocationTable = require("locationTable")
local WorldObjects = class()

function WorldObjects:__create(worldInfo, location, data, appendix)
	local physics = worldInfo.physics
	self.body = location:createBody(physics, "dynamic")
	self.isDestroyed = false
end

function WorldObjects:postCreate(references)
end

function WorldObjects:destroy()
	self.body:destroy()
	self.isDestroyed = true
end

function WorldObjects:getLocation()
	return (LocationTable(self.body))
end

function WorldObjects.createDrawImageFunction(image, width, height)
	local imageWidth  = image:getWidth()
	local imageHeight = image:getHeight()

	local drawWidth  =   width  / imageWidth
	local drawHeight = - height / imageHeight
	local offsetWidth  = imageWidth  / 2
	local offsetHeight = imageHeight / 2

	return function(self, fixture)
		local body = fixture:getBody()
		local x, y = body:getPosition()
		local angle = body:getAngle()

		love.graphics.draw(
			image,
			x, y, angle,
			drawWidth, drawHeight,
			offsetWidth, offsetHeight)
	end
end

return WorldObjects

local LocationTable = require("locationTable")

local lume = require("vendor/lume")

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

function WorldObjects.createDrawImageFunction(imageName, width, height)
	local imageData = {}

	local setup = lume.once(function()
		imageData.image = love.graphics.newImage("res/images/"..imageName..".png")
		local imageWidth, imageHeight = imageData.image:getDimensions()

		imageData.drawWidth  =   width  / imageWidth
		imageData.drawHeight = - height / imageHeight
		imageData.offsetWidth  = imageWidth  / 2
		imageData.offsetHeight = imageHeight / 2
	end)

	return function(self, fixture)
		setup()

		local body = fixture:getBody()
		local x, y = body:getPosition()
		local angle = body:getAngle()

		love.graphics.draw(
			imageData.image,
			x, y, angle,
			imageData.drawWidth, imageData.drawHeight,
			imageData.offsetWidth, imageData.offsetHeight)
	end
end

return WorldObjects

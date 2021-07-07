local LocationTable = require("locationTable")

local lume = require("vendor/lume")

local Draw = {}

local setup = lume.memoize(function(imageName, objectWidth, objectHeight)
	local imageData = {}

	imageData.image = love.graphics.newImage("res/images/"..imageName..".png")
	local imageWidthPx, imageHeightPx = imageData.image:getDimensions()

	imageData.drawWidth    =  objectWidth   / imageWidthPx
	imageData.drawHeight   = -objectHeight  / imageHeightPx
	imageData.offsetWidth  =  imageWidthPx  / 2
	imageData.offsetHeight =  imageHeightPx / 2

	return imageData
end)

function Draw.createObjectDrawImageFunction(imageName, objectWidth, objectHeight)
	local imageData = {}

	return function(self, fixture)
		imageData = setup(imageName, objectWidth, objectHeight)

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

function Draw.createPartDrawImageFunction(imageName)
	local imageData = {}

	return function(self, fixture, scaleByHealth)
		if scaleByHealth then
			local c = self:getScaledHealth()
			love.graphics.setColor(1, c, c, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end

		imageData = setup(imageName, 1, 1)

		local x, y, angle = LocationTable(fixture, self.location):getXYA()

		love.graphics.draw(
			imageData.image,
			x, y, angle,
			imageData.drawWidth, imageData.drawHeight,
			imageData.offsetWidth, imageData.offsetHeight
		)
	end
end

function Draw.createDrawBlockFunction(imageName)
	if not love.graphics then
		return function(x, y, angle) end
	end

	local image = love.graphics.newImage("res/images/"..imageName..".png")
	local imageWidthPx, imageHeightPx = image:getDimensions()

	local drawWidth    =  1 / imageWidthPx
	local drawHeight   = -1 / imageHeightPx
	local offsetWidth  =  imageWidthPx  / 2
	local offsetHeight =  imageHeightPx / 2

	return function(x, y, angle)
			love.graphics.draw(
				image,
				x, y, angle,
				drawWidth, drawHeight,
				offsetWidth, offsetHeight
			)
		end
end

return Draw

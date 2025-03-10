local Draw = {}

function Draw.loadImage(imageName)
	return love.graphics.newImage("res/images/"..imageName..".png")
end

function Draw.createObjectDrawImageFunction(imageName, objectWidth, objectHeight)
	local imageData = {}

	imageData.image = Draw.loadImage(imageName)
	local imageWidthPx, imageHeightPx = imageData.image:getDimensions()

	imageData.drawWidth    =  objectWidth   / imageWidthPx
	imageData.drawHeight   = -objectHeight  / imageHeightPx
	imageData.offsetWidth  =  imageWidthPx  / 2
	imageData.offsetHeight =  imageHeightPx / 2

	return function(self, fixture)
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

function Draw.createDrawBlockFunction(image)
	if not love.graphics then
		return function(x, y, angle) end
	end

	local imageWidthPx, imageHeightPx = image:getDimensions()

	local drawWidth    =  1 / imageWidthPx
	local drawHeight   = -1 / imageHeightPx
	local offsetWidth  =  imageWidthPx  / 2
	local offsetHeight =  imageHeightPx / 2

	return function(x, y, angle, drawMode)
			if drawMode == 4 then
				love.graphics.circle( "fill", x, y, 50 )
			elseif drawMode == 3 then
				love.graphics.circle( "fill", x, y, 5 )
			elseif drawMode == 2 then
				love.graphics.rectangle( "fill", x-0.5, y-0.5, 1, 1)
			else
				love.graphics.draw(
					image,
					x, y, angle,
					drawWidth, drawHeight,
					offsetWidth, offsetHeight
				)
			end
		end
end

return Draw

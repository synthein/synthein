local EntityUtils = {}

function EntityUtils.createDrawImageFunction(image, width, height)
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

return EntityUtils

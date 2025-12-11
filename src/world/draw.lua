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

local teamColors = {}
teamColors[-4] = {1, 0, 1}
teamColors[-3] = {1, 1, 0}
teamColors[-2] = {0, 1, 0}
teamColors[-1] = {1, 0.5, 0}
teamColors[ 0] = {1, 1, 1}
teamColors[ 1] = {1, 0, 0}
teamColors[ 2] = {0, 0, 1}

local plainBlockSize = 20
local plainBlockScale = 1/plainBlockSize
local plainBlockOffset = plainBlockSize/2
local plainBlock = love.graphics.newCanvas(plainBlockSize, plainBlockSize)
love.graphics.setCanvas(plainBlock)
love.graphics.clear(1, 1, 1)
love.graphics.setCanvas()


function Draw.createDrawBlockFunction(image)
	if not love.graphics then
		return function(x, y, angle) end
	end

	local imageWidthPx, imageHeightPx = image:getDimensions()

	local drawWidth    =  1 / imageWidthPx
	local drawHeight   = -1 / imageHeightPx
	local offsetWidth  =  imageWidthPx  / 2
	local offsetHeight =  imageHeightPx / 2

	return function(x, y, angle, drawMode, team, zoom)
			if drawMode == 3 then
				love.graphics.setColor(unpack(teamColors[team]))
				love.graphics.circle( "fill", x, y, 5 * (1 + 1/zoom))
			elseif drawMode == 2 then
				love.graphics.setColor(unpack(teamColors[team]))
				love.graphics.draw(
					plainBlock,
					x, y, angle,
					plainBlockScale, plainBlockScale,
					plainBlockOffset, plainBlockOffset
				)
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

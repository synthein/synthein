local vector = require("vector")

local CircleMenu = {}

function CircleMenu.indexToAngle(index, division, startAngle)
	-- This system is layed out like a clock face
	-- startAngle	for if the menu rotates with the object
	-- -			converts it from clockwise to counterclockwise
	-- * math.pi	changes 0 to 2 into 0 to 2pi
	-- -0.5			sets index 1 to the noon position
	-- / division	changes 0 to 2division into 0 to 2
	-- -1			causes the center of index 1 to be straight up
	-- * 2 			changes 0 to division into 0 to 2division
	return startAngle - math.pi * (-0.5 + ((index) * 2 - 1) / division)
end

function CircleMenu.angleToIndex(angle, length)
	return math.floor(((-angle/math.pi + 0.5) * length + 1)/2 % length + 1)
end

function CircleMenu.draw(x, y, angle, size, strength, labels)
	local division = #strength

	-- Function that defines the lines seperating the arc segments
	local function stencilCallback()
		love.graphics.setLineWidth(size/5)

		-- One line from the center to the edge for each segment of the arc
		for i = 1, division do
			local angleToPoint = CircleMenu.indexToAngle(i, division, angle)
			local pointX, pointY = vector.components(5 * size, angleToPoint)
			pointX = pointX + x
			pointY = pointY + y
			love.graphics.line(x, y, pointX, pointY)
		end
	end

	-- Setup the stencil to prevent
	love.graphics.stencil(stencilCallback, "replace", 1)
	love.graphics.setStencilTest("equal", 0)

	-- Set thickness of arc
	love.graphics.setLineWidth(size/2)

	for i, color in ipairs(strength) do
		if color ~= 0 then
			if color == 1 then
				-- Set color to medium blue
				love.graphics.setColor(0.125, 0.25, 0.5625, 0.75)
			elseif color == 2 then
				-- Set color to light blue
				love.graphics.setColor(0.3125, 0.5, 0.75, 0.75)
			end

			-- Draw arc segment
			love.graphics.arc("line", "open", x, y, 1.75 * size,
							  CircleMenu.indexToAngle(i - 1, division, angle),
							  CircleMenu.indexToAngle(i, division, angle),
							  30)
		end
	end

	-- Clear stencil
	love.graphics.setStencilTest()

	-- Set color to light blue
	love.graphics.setColor(0.3125, 0.5, 0.75, 0.75)

	-- Set font
	local previousFont = love.graphics.getFont()
	local font = love.graphics.newFont(size * 50)
	love.graphics.setFont(font)

	-- Print labels
	if labels then
		for i = 1, division do
			local angleToText = CircleMenu.indexToAngle(i - .5, division, angle)
			local textX, textY = vector.components(3 * size, angleToText)
			textX = textX + x
			textY = textY + y
			love.graphics.print(labels[i], textX, textY, 0,
								1/100, -1/100,
								size * 12.5 * #labels[i], size * 25)
		end
	end

	-- Set color to whie
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(previousFont)
end

return CircleMenu

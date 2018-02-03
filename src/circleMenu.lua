local Util = require("util")

local CircleMenu = {}

function CircleMenu.create(camera)
	local self = {}

	self.camera = camera
	self.draw = self.camera.wrap(CircleMenu.draw, true)

	return self
end

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

function CircleMenu:draw(x, y, angle, size, strength)
	local division = #strength

	-- Function that defines the lines seperating the arc segments
	local function stencilCallback()
		love.graphics.setLineWidth(size/5)

		-- One line from the center to the edge for each segment of the arc
		for i = 1, division do
			local angleToPoint = CircleMenu.indexToAngle(i, division, angle)
			local pointX, pointY = Util.vectorComponents(5 * size, angleToPoint)
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
				love.graphics.setColor(32, 64, 144, 192)
			elseif color == 2 then
				-- Set color to light blue
				love.graphics.setColor(80, 128, 192, 192)
			end

			-- Draw arc segment
			love.graphics.arc("line", "open", x, y, 1.75 * size,
							  CircleMenu.indexToAngle(i - 1, division, angle),
							  CircleMenu.indexToAngle(i, division, angle),
							  30)
		end
	end

	-- Set color to whie
	love.graphics.setColor(255, 255, 255, 255)
	-- Clear stencil
	love.graphics.setStencilTest()
end

return CircleMenu

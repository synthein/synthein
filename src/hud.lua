--local PhysicsReferences = require("world/physicsReferences")
--local Settings = require("settings")
--local vector = require("vector")

local Hud = class()

function Hud:__create()
	return self
end

function Hud:drawCompass(angle)
	local scissor = self.scissor
	local width = scissor.width
	local height = scissor.height

	-- Draw the compass in the lower right hand corner.
	local compassSize = 20
	local compassPadding = 10
	local compassX = width - compassSize - compassPadding
	local compassY = height - compassSize - compassPadding

	love.graphics.circle(
		"line",
		compassX,
		compassY,
		compassSize
	)
	local needleX, needleY = vector.components(
		compassSize,
		angle
	)
	love.graphics.polygon(
		"fill",
		compassX - needleX * 0.1,
		compassY - needleY * 0.1,
		compassX + needleY * 0.1,
		compassY - needleX * 0.1,
		compassX + needleX,
		compassY + needleY,
		compassX - needleY * 0.1,
		compassY + needleX * 0.1
	)
end

function Hud:draw(player)
	love.graphics.setColor(31/255, 63/255, 143/255, 95/255)
	local drawPoints = love.graphics.points
	for _, list in ipairs(player.shieldPoints) do
		drawPoints(unpack(list))
	end
	love.graphics.setColor(1, 1, 1, 1)

	local cursorX, cursorY = player.camera:getWorldCoords(player.cursorX, player.cursorY)

	if player.menu then
		player.partSelector:draw()
	end

	local scissor = self.scissor
	local screenWidth = scissor.width
	local screenHeight = scissor.height

	local point = {0,0}
	if player.ship then
		local leader = (player.ship.corePart or {}).leader
		if leader then
			point = leader:getLocation()
		end
		if player.ship.isDestroyed then
			player.ship = nil
		end
	else
		local previousFont = love.graphics.getFont()
		local font = love.graphics.newFont(20)
		love.graphics.setFont(font)
		love.graphics.print("Game Over", 10, screenHeight - 30, 0, 1, 1, 0, 0, 0, 0)
		love.graphics.setFont(previousFont)
	end

	local compassAngle = math.atan2(self.x - point[1], self.y - point[2])
		+ math.pi/2
		+ (player.isCameraAngleFixed and 0 or self.angle)

	self:drawCompass(compassAngle)

	-- Draw the cursor.
	love.graphics.draw(player.cursor, player.cursorX - 2, player.cursorY - 2)

	-- Draw a box around the entire region.
	--TODO double check this on two Player
	love.graphics.rectangle(
		"line",
		0,
		0,
		screenWidth,
		screenHeight
	)
	
	--TODO double check this on two Player
	love.graphics.rectangle(
		"fill",
		screenWidth - 150,
		0,
		screenWidth,
		120
	)
end

return Hud

Player = {}
Player.__index = Player

function Player.create()
	local self = setmetatable({}, Player)

	self.image = love.graphics.newImage("player.png")
	self.playerAngle = 0

	return self
end

function Player:update(dt)
	if love.keyboard.isDown("left") then
		self.playerAngle = self.playerAngle - 1
	end

	if love.keyboard.isDown("right") then
		self.playerAngle = self.playerAngle + 1
	end
end

function Player:draw()
	love.graphics.draw(self.image, 100, 100, math.rad(self.playerAngle), 1, 1, 10, 10)
end

return Player

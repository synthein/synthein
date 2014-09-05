Player = {}
Player.__index = Player

function Player.create(world)
	local self = setmetatable({}, Player)

	self.image = love.graphics.newImage("player.png")
	self.playerAngle = 0
	self.x = 100
	self.y = 100
	self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
	self.shape = love.physics.newRectangleShape(20, 20)
	self.fixture = love.physics.newFixture(self.body, self.shape)

	return self
end

function Player:update(dt)
	if love.keyboard.isDown("left") then
		self.body:applyTorque(-10)
	end

	if love.keyboard.isDown("right") then
		self.body:applyTorque(10)
	end
end

function Player:draw()
	love.graphics.draw(self.image, self.x, self.y, self.body:getAngle(), 1, 1,
	                   10, 10)
end

return Player

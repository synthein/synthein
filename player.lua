Player = {}
Player.__index = Player

function Player.create(world)
	local self = setmetatable({}, Player)

	self.image = love.graphics.newImage("player.png")
	self.playerAngle = 0
	self.body = love.physics.newBody(world, 100, 100, "dynamic")
	self.shape = love.physics.newRectangleShape(20, 20)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.body:setAngularDamping(1)
	self.body:setLinearDamping(1)

	return self
end

function Player:update(dt)
	if love.keyboard.isDown("up") then
		self.body:applyForce(30*math.cos(self.body:getAngle()-0.5*math.pi),
		                     30*math.sin(self.body:getAngle()-0.5*math.pi))
	end
	if love.keyboard.isDown("down") then
		self.body:applyForce(-(10*math.cos(self.body:getAngle()-0.5*math.pi)),
		                     -(10*math.sin(self.body:getAngle()-0.5*math.pi)))
	end
	if love.keyboard.isDown("left") then
		self.body:applyTorque(-80)
	end

	if love.keyboard.isDown("right") then
		self.body:applyTorque(80)
	end
end

function Player:draw()
	love.graphics.draw(self.image, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1,
	                   10, 10)
end

return Player

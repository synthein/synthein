Player = {}
Player.__index = Player

function Player.create(world, x, y)
	local self = setmetatable({}, Player)

	self.image = love.graphics.newImage("player.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.body = love.physics.newBody(world, x, y, "dynamic")
	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.fixture = love.physics.newFixture(self.body, self.shape)

	self.thrust = 150
	self.torque = 350
	self.body:setAngularDamping(1)
	self.body:setLinearDamping(0.5)

	return self
end

function Player:update(dt)
	if love.keyboard.isDown("up") then
		self.body:applyForce(
			self.thrust*math.cos(self.body:getAngle()-0.5*math.pi),
			self.thrust*math.sin(self.body:getAngle()-0.5*math.pi))
	end
	if love.keyboard.isDown("down") then
		self.body:applyForce(
			-self.thrust*math.cos(self.body:getAngle()-0.5*math.pi),
		    -self.thrust*math.sin(self.body:getAngle()-0.5*math.pi))
	end
	if love.keyboard.isDown("left") then
		self.body:applyTorque(-self.torque)
	end

	if love.keyboard.isDown("right") then
		self.body:applyTorque(self.torque)
	end
end

function Player:draw()
	love.graphics.draw(self.image, love.graphics.getWidth()/2,
	                   love.graphics.getHeight()/2, self.body:getAngle(),
					   1, 1, self.width/2, self.height/2)
end

return Player

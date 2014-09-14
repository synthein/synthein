Input = {}
Input.__index = Input

function Input.create(type, structure)
	local self = {}
	setmetatable(self, Input)

	self.structure = structure

	if type == "player1" then
		self.forward = "w"
		self.back = "s"
		self.left = "a"
		self.right = "d"
		self.strafeLeft = "j"
		self.strafeRight = "k"
	elseif type =="player2" then
	elseif type == "AI" then
	end

	return self
end

function Input:handleInput()
	local orders = {}

	if love.keyboard.isDown(self.forward) then
		table.insert(orders, "forward")
	end
	if love.keyboard.isDown(self.back) then
		table.insert(orders, "back")
	end
	if love.keyboard.isDown(self.left) then
		table.insert(orders, "left")
	end
	if love.keyboard.isDown(self.right) then
		table.insert(orders, "right")
	end
	if love.keyboard.isDown(self.strafeLeft) then
		table.insert(orders, "strafeLeft")
	end
	if love.keyboard.isDown(self.strafeRight) then
		table.insert(orders, "strafeRight")
	end

	self.structure:command(orders)
end

return Input

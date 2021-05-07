local Block = class(require("world/shipparts/part"))

function Block:__create()
	self.image = "block"
	self.width, self.height = 1, 1
end

return Block

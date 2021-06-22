local Hull = require("world/shipparts/hull")

local Block = class(require("world/shipparts/part"))

function Block:__create()
	self.modules["hull"] = Hull("block", 10)
end

return Block

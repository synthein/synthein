local Draw = require("world/draw")
local imageFunction = Draw.createDrawBlockDrawFunction("gun")

-- Component
local Hull = require("world/shipparts/hull")
local Gun = require("world/shipparts/gun")

local GunBlock = class(require("world/shipparts/part"))

function GunBlock:__create()
	self.modules["hull"] = Hull(imageFunction, 10)

	self.modules["gun"] = Gun()

	-- GunBlocks can only connect to things on their bottom side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	return self
end

return GunBlock

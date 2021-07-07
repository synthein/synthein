-- Components
local Hull = require("world/shipparts/hull")
local Gun = require("world/shipparts/gun")

-- Graphics
local Draw = require("world/draw")
local imageFunction = Draw.createDrawBlockFunction("gun")

-- Class Setup
local Part = require("world/shipparts/part")
local GunBlock = class(Part)

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

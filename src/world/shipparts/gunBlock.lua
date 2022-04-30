-- Components
local Hull = require("world/shipparts/hull")
local Gun = require("world/shipparts/gun")

-- Class Setup
local Part = require("world/shipparts/part")
local GunBlock = class(Part)

-- Graphics
local Draw = require("world/draw")
GunBlock.image = Draw.loadImage("gun")
local imageFunction = Draw.createDrawBlockFunction(GunBlock.image)

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

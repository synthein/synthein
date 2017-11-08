--[[
local Block = require("shipparts/block")
local EngineBlock = require("shipparts/engineBlock")
local GunBlock = require("shipparts/gunBlock")
local AIBlock = require("shipparts/aiBlock")
local PlayerBlock = require("shipparts/playerBlock")
local Anchor = require("shipparts/anchor")

Block.partChar = 'b'
EngineBlock.partChar = 'e'
GunBlock.partChar = 'g'
AIBlock.partChar = 'a'
PlayerBlock.partChar = 'p'
Anchor.partChar = 'n'
--]]

local partsList = {
b = require("shipparts/block"),
e = require("shipparts/engineBlock"),
g = require("shipparts/gunBlock"),
a = require("shipparts/aiBlock"),
p = require("shipparts/playerBlock"),
n = require("shipparts/anchor")
}

local PartRegistry = {}

function PartRegistry.setPartChars()
	for k,v in pairs(partsList) do
		v.partChar = k
	end
end

function PartRegistry.createPart(partChar,data)
	if not data then
		data = {}
	end
	return partsList[partChar].create(unpack(data))
end

return PartRegistry

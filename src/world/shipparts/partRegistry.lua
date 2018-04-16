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
local directory = "world/shipparts/"

local partsList = {
b = require(directory .. "block"),
e = require(directory .. "engineBlock"),
g = require(directory .. "gunBlock"),
a = require(directory .. "aiBlock"),
p = require(directory .. "playerBlock"),
n = require(directory .. "anchor")
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

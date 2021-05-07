local PartRegistry = {}

PartRegistry.partsList = {
b = require("world/shipparts/block"),
e = require("world/shipparts/engineBlock"),
g = require("world/shipparts/gunBlock"),
a = require("world/shipparts/aiBlock"),
p = require("world/shipparts/playerBlock"),
n = require("world/shipparts/anchor"),
m = require("world/shipparts/armorBlock"),
s = require("world/shipparts/shieldBlock"),
r = require("world/shipparts/repairBlock"),
}

function PartRegistry.setPartChars()
	for k,v in pairs(PartRegistry.partsList) do
		v.partChar = k
	end
end

function PartRegistry.createPart(partChar,data)
	if not data then
		data = {}
	end
	return PartRegistry.partsList[partChar](unpack(data))
end

return PartRegistry

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
l = require("world/shipparts/missileLauncherBlock"),
}

PartRegistry.allParts = {}
PartRegistry.coreParts = {}
PartRegistry.noncoreParts = {}
PartRegistry.isCorePart = {
	a = true,
	p = true,
	n = true,
}

for k, v in pairs(PartRegistry.partsList) do
	table.insert(PartRegistry.allParts, k)
	if PartRegistry.isCorePart[k] then
		table.insert(PartRegistry.coreParts, k)
	else
		table.insert(PartRegistry.noncoreParts, k)
	end
end

function PartRegistry.setPartChars()
	for k,v in pairs(PartRegistry.partsList) do
		v.partChar = k
	end
end

function PartRegistry.createPart(partChar,data)
	return PartRegistry.partsList[partChar](unpack(data or {}))
end

return PartRegistry

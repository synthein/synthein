local PhysicsReferences = {}

--- Types
--camera		players/what ships see
--visual		animations
--shields
--projectiles
--missile
--general		basic physics bodies

-- Main reference tables
local isSensor
PhysicsReferences.categories = {}
local categories = PhysicsReferences.categories
local masks = {}
local groups = {}

-- Physical bodies are set to false
isSensor = {
	camera = true,
	visual = true,
	shield = true,
	projectiles = true,
	missile = false,
	general = false,
}

--If a collision occurs the fixture with the category that comes first will have
--the collision function called on them. If the two fixtures of the same type
--the collison function will be called on both.
local catergoryOrder = {
	"camera", --players/what ships see
	"visual", --animations
	"shield",
	"projectiles",
	"missile",
	"general", --basic physics bodies
}

--Generate category values.
local bit = 1
for _, v in ipairs(catergoryOrder) do
	categories[v] = bit
	bit = bit *2
end

--Anything included collides. It is required for both that are involed to
--include the other.

local maskList = {
	camera = {"visual", "shield", "projectiles", "missile", "general"},
	visual = {"camera"},
	shield = {"camera", "projectiles"},
	projectiles = {"camera", "shield", "projectiles", "missile", "general"},
	missile = {"camera", "projectiles", "missile", "general"},
	general = {"camera", "projectiles", "missile", "general"},
}

for k, t in pairs(maskList) do
	local mask = 0
	for i, v in ipairs(t) do
		mask = mask + categories[v]
	end
	masks[k] = mask
end

--Groups determine if they collide with themselfs
local collision = {"missile", "general"}
local noCollision = {"camera", "visual", "shield", "projectiles"}

for i, v in ipairs(collision) do
	groups[v] = i
end

for i, v in ipairs(noCollision) do
	groups[v] = -i
end

function PhysicsReferences.getCategory(type)
	return categories[type]
end

function PhysicsReferences.setFixtureType(fixture, type)
	if categories[type] == nil then
		error(string.format("There is no such type %q", type), 2)
	end

	fixture:setSensor(isSensor[type])
	if isSensor[type] then
		fixture:setDensity(0)
		fixture:getBody():resetMassData()
	else
		fixture:setRestitution(0.1)
	end
	fixture:setFilterData(categories[type], masks[type], groups[type])
end

return PhysicsReferences

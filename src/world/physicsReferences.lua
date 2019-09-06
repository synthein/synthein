local PhysicsReferences = {}

--- Types
--cameras		players/what ships see
--visual		animations
--shields
--projectiles
--general		basic physics bodies

-- Main reference tables
local isSensor
local categories = {}
local masks = {}
local groups = {}

-- Physical bodies are set to false
isSensor = {
	camera = true,
	visual = true,
	shield = true,
	projectiles = true,
	general = false
}

--If a collision occurs the fixture with the category that comes first will have
--the collision function called on them. If the two fixtures of the same type
--the collison function will be called on both.
local catergoryOrder = {
	"camera", --players/what ships see
	"visual", --animations
	"shield",
	"projectiles",
	"general" --basic physics bodies
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
	camera = {"visual", "shield", "projectiles", "general"},
	visual = {"camera"},
	shield = {"camera", "projectiles"},
	projectiles = {"camera", "shield", "projectiles", "general"},
	general = {"camera", "projectiles", "general"}
}

for k, t in pairs(maskList) do
	local mask = 0
	for i, v in ipairs(t) do
		mask = mask + categories[v]
	end
	masks[k] = mask
end

--Groups determine if they collide with themselfs
local collision = {"missiles", "general"}
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
	fixture:setSensor(isSensor[type])
	if isSensor[type] then
		fixture:setDensity(0)
	else
		fixture:setRestitution(0.1)
	end
	fixture:setFilterData(categories[type], masks[type], groups[type])
end

return PhysicsReferences

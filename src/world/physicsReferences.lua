local PhysicsReferences = {}

--Contact Filter references
--Fixture Categories

local fixtures = {categories = {}, masks = {}, groups ={}}
local categories = fixtures.categories
--local masks = fixtures.mask
local groups = fixtures.groups


--If a collision occurs the fixture with the category that comes first will have
--the collision function called on them. If the two fixtures of the same type
--the collison function will be called on both.
local catergoryOrder = {
	"cameras", --players/what ships see
	"visual", --animations
	"shields",
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
--[[
masks = {
	camera = {"visual", "shields", "projectiles", "general"},
	visual = {"cameras"},
	shield = {"cameras", "projectiles"},
	projectile = {"cameras", "shields", "projectiles", "general"},
	general = {"cameras", "projectiles", "general"}
}
--]]
--Groups determine if they collide with themselfs
local collision = {"missiles", "general"}
local noCollision = {"cameras", "visual", "shields", "projectiles"}

for i, v in ipairs(collision) do
	groups[v] = i
end

for i, v in ipairs(noCollision) do
	groups[v] = -i
end

return PhysicsReferences

local Part = require("shipparts/part")
local Screen = require("screen")
local Settings = require("settings")

local Engine = {}
Engine.__index = Engine
setmetatable(Engine, Part)

Engine.orientationVectors = {
	{ 0,  1},
	{-1,  0},
	{ 0, -1},
	{ 1,  0}}

Engine.rotationTable = {
	{ 1, 1}, --  x
	{ 1, 2}, --  y
	{-1, 1}, -- -x
	{-1, 2}} -- -y

Engine.directionTable = {
	{-1, 2, 1, 1}, -- -y,  x	90
	{-1, 1,-1, 2}, -- -x, -y	180
	{ 1, 2,-1, 1}, --  y, -x	270
	{ 1, 1, 1, 2}} --  x,  y	0

function Engine.create(world, x, y)
	local self = Part.create()
	setmetatable(self, Engine)

	self.imageInactive = love.graphics.newImage("res/images/engine.png")
	self.imageActive = love.graphics.newImage("res/images/engineActive.png")
	self.image = self.imageInactive
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.isActive = false

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)

	-- Engines can only connect to things on their top side.
	self.connectableSides[2] = false
	self.connectableSides[3] = false
	self.connectableSides[4] = false

	self.thrust = 250

	return self
end

function Engine:update(dt, partsInfo, location, locationSign, orientation)
	self.location = location
	self.orientation = orientation
	local body = self.fixture:getBody()
	if self.location and body and partsInfo.engines then
		local angle = (self.orientation - 1) * math.pi/2 + body:getAngle()

		local engines = partsInfo.engines
		local r = Engine.rotationTable[self.orientation]
		local rotation = r[1]*locationSign[r[2] ]
		on = engines[self.orientation] + engines[7]*rotation

		if on > 0 then
			self.isActive = true
		else
			self.isActive = false
		end
		
		if self.isActive then
			local x, y = unpack(self.location)
			x, y = body:getWorldPoints(x * Settings.PARTSIZE,
									   y * Settings.PARTSIZE)
			local fx, fy = body:getWorldVector(unpack(Engine.orientationVectors[self.orientation]))
			body:applyForce(fx * self.thrust, fy * self.thrust, x, y)
		end
	else
		self.isActive = false
	end
	if self.isActive then
		self.image = self.imageActive
	else
		self.image = self.imageInactive
	end
end

return Engine

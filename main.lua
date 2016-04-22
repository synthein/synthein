local Debug = require("debugTools")
local Player = require("player")
local Structure = require("structure")
local World = require("world")

-- These are global for now.
--local globalOffsetX
--local globalOffsetY

local physics
local player1

function love.load()
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	compass = love.graphics.newImage("res/images/compass.png")
	debugmode = true
	
	love.physics.setMeter(20) -- there are 20 pixels per meter
	physics = love.physics.newWorld()
	world = World.create(physics)
	player1 = Player.create("player1", world:getPlayerShip())
end

function love.update(dt)
	physics:update(dt)
	world:update(dt)
	player1:handleInput(globalOffsetX, globalOffsetY)

	globalOffsetX = player1.ship.body:getX()
	globalOffsetY = player1.ship.body:getY()

	-- TODO: move this to love.mousepressed()
	if debugmode == true then
		Debug.mouse(globalOffsetX, globalOffsetY)
	end
end

function love.draw()
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()

	world:draw()
	love.graphics.draw(
		compass,
		SCREEN_WIDTH-60,
	    SCREEN_HEIGHT-60,
		math.atan2(globalOffsetY, globalOffsetX)-math.pi/2,
		1, 1, 25, 25)

	if quitting then
		love.graphics.print(
			"Do you want to quit?",
		    SCREEN_WIDTH/2-64,
			SCREEN_HEIGHT/2-30)
	end

	--------------------
	---- Debug Info ----
	--------------------
	if debugmode then
		local debugString = string.format(
			"%.3f    %.3f\n"..
			"Number of world structures: %d\n"..
			"Build mode: %s\n",
			globalOffsetX, globalOffsetY,
			#world.worldStructures,
			(player1.isBuilding and "yes" or "no")
		)
		love.graphics.print(debugString, 5, 5)
	end
	--------------------
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
	if key == "f12" then debugmode = not debugmode end

	if debugmode == true then
		Debug.keyboard(key, globalOffsetX, globalOffsetY)
	end
end

function love.mousepressed(x, y, button, istouch)
	player1:mousepressed(x, y, button)
end


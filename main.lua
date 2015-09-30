local Debug = require("debugTools")
local InitWorld = require("initWorld")
local Player = require("player")
local Structure = require("structure")

-- These are global for now.
--local globalOffsetX
--local globalOffsetY

function love.load()
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	compass = love.graphics.newImage("res/images/compass.png")
	debugmode = true

	world, worldStructures, anchor, player1, playerShip = InitWorld.init()
end

function love.update(dt)
	world:update(dt)
	playerShip:update()
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

	anchor:draw(globalOffsetX, globalOffsetY)
	for i, structure in ipairs(worldStructures) do
		structure:draw(globalOffsetX, globalOffsetY)
	end
	player1:draw(globalOffsetX, globalOffsetY)
	love.graphics.draw(
		compass,
		SCREEN_WIDTH-60,
	    SCREEN_HEIGHT-60,
		math.atan2(playerShip.body:getY(),
		playerShip.body:getX())-math.pi/2,
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
			#worldStructures,
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

function love.mousepressed(x, y, button)
	player1:mousepressed(x, y, button)
end


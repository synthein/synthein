local Anchor = require("anchor")
local Block = require("block")
local Engine = require("engine")
local Player = require("player")
local PlayerBlock = require("playerBlock")
local Structure = require("structure")

function love.load()
	love.physics.setMeter(20) -- there are 20 pixels per meter
	world = love.physics.newWorld()

	compass = love.graphics.newImage("res/images/compass.png")

	-- Create the player.
	playerShip = Structure.create(PlayerBlock.create(), world, 0, -100)
	player1 = Player.create("player1", playerShip)

	-- Create the anchor.
	anchor = Structure.create(Anchor.create(), world, -10, -10)
	anchor:addPart(Anchor.create(), 1, 20, 0)
	anchor:addPart(Anchor.create(), 1, 0, 20)
	anchor:addPart(Anchor.create(), 1, 20, 20)

	worldStructures = {}
	for i=1,10 do
		worldStructures[i] = Structure.create(Block.create(), world, i*35, i*35)
	end

	debugmode = true
end

function love.update(dt)
	world:update(dt)
	globalOffsetX = player1.ship.body:getX()
	globalOffsetY = player1.ship.body:getY()
	player1:handleInput()
end

function love.draw()
	anchor:draw(globalOffsetX, globalOffsetY)
	for i, structure in ipairs(worldStructures) do
		structure:draw(globalOffsetX, globalOffsetY)
	end
	player1:draw(globalOffsetX, globalOffsetY)
	love.graphics.draw(compass, love.graphics.getWidth()-60, love.graphics.getHeight()-60, math.atan2(playerShip.body:getY(), playerShip.body:getX())-math.pi/2, 1, 1, 25, 25)

	--------------------
	---- Debug Info ----
	--------------------
	if debugmode then
		local debugString = string.format(
			"%.3f    %.3f\n"..
			"Number of world structures: %d\n"..
			"Selection mode: %s\n",
			globalOffsetX, globalOffsetY,
			#worldStructures,
			(player1.selection and player1.selection.mode or "no")
		)
		love.graphics.print(debugString, 5, 5)
	end
	--------------------
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
	if key == "f12" then debugmode = not debugmode end

	--------------------
	-- Debug Commands --
	--------------------
	if debugmode == true then
		-- Spawn a block
		if key == "u" then
			table.insert(worldStructures,
				Structure.create(Block.create(), world,
				globalOffsetX + 50, globalOffsetY - 100))
		end
		-- Spawn an engine
		if key == "i" then
			table.insert(worldStructures,
				Structure.create(Engine.create(), world,
				globalOffsetX + 112, globalOffsetY))
		end
	end
	--------------------
end

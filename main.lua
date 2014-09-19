local Anchor = require("anchor")
local Block = require("block")
local Input = require("input")
local Player = require("player")
local Structure = require("structure")

function love.load()
	love.physics.setMeter(20) -- there are 20 pixels per meter
	world = love.physics.newWorld()

	compass = love.graphics.newImage("res/images/compass.png")
	playerShip = Structure.create(Player.create(), world, 0, -100)
	anchor = Structure.create(Anchor.create(), world, 0, 0)

	player1 = Input.create("player1", playerShip)

	worldStructures = {}
	for i=1,10 do
		worldStructures[i] = Structure.create(Block.create(), world, i*35, i*35)
	end

	worldStructures[1]:merge(worldStructures[2], worldStructures[2].parts[1], worldStructures[1].parts[1], "right")
	table.remove(worldStructures, 2)
	worldStructures[2]:merge(worldStructures[3], worldStructures[3].parts[1], worldStructures[2].parts[1], "right")
	table.remove(worldStructures, 3)
	
	debugmode = true
end

function love.update(dt)
	world:update(dt)
	globalOffsetX = player1.structure.body:getX()
	globalOffsetY = player1.structure.body:getY()
	player1:handleInput(dt)
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
	if debugmode == true then
		love.graphics.print(globalOffsetX.."    "..globalOffsetY, 5, 5)
		love.graphics.print("number of world structures: "..#worldStructures, 5, 20)
		love.graphics.print("Are we in selection mode?  "..(player1.selection and "yes" or "no"), 5, 35)
	end
	--------------------
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit") end
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
	if key == "f12" then debugmode = not debugmode end

	--------------------
	-- Debug Commands --
	--------------------
	if debugmode == true then
		-- Spawn a block
		if key == "u" then
			table.insert(worldStructures, Structure.create(Block.create(),
				world, globalOffsetX + 50, globalOffsetY - 100))
		end
	end
	--------------------
end

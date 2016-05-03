local Debug = require("debugTools")
local InGame = require("inGame")
local World = require("world")
local Player = require("player")
local Structure = require("structure")


local NewGame = {}

function NewGame.update(mouseWorldX, mouseWorldY)
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	compass = love.graphics.newImage("res/images/compass.png")
	debugmode = true
	
	love.physics.setMeter(20) -- there are 20 pixels per meter
	physics = love.physics.newWorld()
	world = World.create(physics)
	player1 = Player.create("player1", world:getPlayerShip())
	globalOffsetX = player1.ship.body:getX()
	globalOffsetY = player1.ship.body:getY()
	InGame.setWorld(world)



	Debug.setWorld(world)
	Debug.setPlayer(player1)
	return InGame
end

function NewGame.draw()
	return NewGame
end

function NewGame.keypressed(key)
	return NewGame
end

function NewGame.mousepressed(mouseX, mouseY, button, mouseWorldX, mouseWorldY)
	return NewGame
end

function NewGame.mousereleased(x, y, button, mouseWorldX, mouseWorldY)
	return NewGame
end

return NewGame

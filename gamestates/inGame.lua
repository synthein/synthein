local Debug = require("debugTools")
local Player = require("player")
local Structure = require("structure")
local World = require("world")
local Screen = require("screen")
local Util = require("util")
local SceneParser = require("sceneParser")

local GameState = require("gamestates/gameState")

local InGame = {}
setmetatable(InGame, GameState)

local world
local players = {}
local paused = false
local eventTime = 0
local second = 0

local pauseMenu = {}
pauseMenu.font = love.graphics.newFont(18)
pauseMenu.buttons = {"Save", "Quit"}
local typingSaveName = false
local saveName = ""

function InGame.setplayers(playerTable)
	players = playerTable
end

function InGame.setWorld(setworld)
	world = setworld
end

function InGame.update(dt)
	if paused then
	else
		-- Update the game world.
		Structure.physics:update(dt)
		if players[1].ship then
			Screen.camera:setX(players[1].ship.body:getX())
			Screen.camera:setY(players[1].ship.body:getY())
		end

		players[1]:handleInput(Screen.camera:getPosition())
		world:update(dt)

		eventTime = eventTime + dt
		second = second + dt
		if second > 1 then
			if players[1].ship then
				timeVar = 1 - 50/(20 + eventTime)
				if timeVar < 0 then timeVar = 0 end
				disVar = 1 - 50/(1 + Util.vectorMagnitude(
							players[1].ship.body:getX(),players[1].ship.body:getY())/20)
				if disVar < 0 then disVar = 0 end
				veloVar = 1 - 50/(1 + Util.vectorMagnitude(
							players[1].ship.body:getLinearVelocity()))
				if veloVar < 0 then veloVar = 0 end
				rand = love.math.random()
				if rand < timeVar * disVar * veloVar then
					eventTime = 0
					local scene = math.ceil(love.math.random() * 10)
					scene = tostring(scene)
					SceneParser.loadScene("scene" .. scene, {players[1].ship.body:getX(),players[1].ship.body:getY()})
				end
			end
			second = second - 1
		end
	end

	-- Save the game.
	if not typingSaveName and #saveName > 0 then
		SceneParser.saveScene("saves/" .. saveName, world)
		saveName = ""
	end

	if debugmode then Debug.update(mouseWorldX, mouseWorldY) end

	return InGame
end

function InGame.draw()
	-- for camera in InGame.cameras do
		cameraX, cameraY = Screen.camera:getPosition()
	--todo move to Camera/Screen
		--love.graphics.translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
		--love.graphics.translate(-cameraX, cameraY)
	--
		world:draw()
		players[1].cursorX = love.mouse.getX()
		players[1].cursorY = love.mouse.getY()
		players[1]:draw()
		love.graphics.origin()
		love.graphics.draw(
			compass,
			SCREEN_WIDTH-60,
			SCREEN_HEIGHT-60,
			-math.atan2(cameraY, cameraX)-math.pi/2,
			1, 1, 25, 25)
	-- end
	if paused then
		love.graphics.print("Paused", SCREEN_WIDTH/2-24, 30)
	end
	if menuOpen then
		local previousFont = love.graphics.getFont()
		love.graphics.setFont(pauseMenu.font)
		button_width = 500
		button_height = 50
		text_height = 40

		-- Draw a background box behind the menu.
		love.graphics.setColor(200, 200, 200)
		love.graphics.rectangle("fill",
			(SCREEN_WIDTH - button_width)/2 - 25,
			150 + 75,
			button_width + 50,
			#pauseMenu.buttons * (button_height + 25) + 25)

		-- Draw the buttons.
		for i,button in ipairs(pauseMenu.buttons) do
			love.graphics.setColor(100, 100, 100)
			love.graphics.rectangle("fill", (SCREEN_WIDTH - button_width)/2, 175 + 75 * i, button_width, button_height)
			love.graphics.setColor(255, 255, 255)
			love.graphics.print(button, (SCREEN_WIDTH - button_width)/2 + 10, 175 + 75 * i + button_height/2 - text_height/2, 0, 1, 1, 0, 0, 0, 0)
		end
		love.graphics.setFont(previousFont)
	end
	if typingSaveName then
		love.graphics.print("Type a name to use for your save, then press enter:", SCREEN_WIDTH/2-150, 60)
		love.graphics.print(saveName, SCREEN_WIDTH/2-150, 90)
	end

	-- Print debug info.
	if debugmode then Debug.draw() end

	return InGame
end

function InGame.keypressed(key)
	if typingSaveName then
		if key:match("^%w$") then
			saveName = saveName .. key
		elseif key == "backspace" then
			saveName = saveName:sub(1, -2)
		elseif key == "return" then
			typingSaveName = false
		elseif key == "escape" then
			saveName = ""
			typingSaveName = false
		end
	else
		if key == "p" or key == "pause" then
			paused = not paused
		end
	end

	if debugmode == true then
		Debug.keyboard(key, Screen.camera:getX(), Screen.camera:getY())
	end

	return InGame
end

function InGame.mousepressed(x, y, mouseButton)
	players[1].cursorX = x
	players[1].cursorY = y
	players[1]:mousepressed(mouseButton)

	if menuOpen then
		if mouseButton == 1 then
			if x < (SCREEN_WIDTH - button_width)/2 or x > (SCREEN_WIDTH + button_width)/2 then
				return InGame
			end
			local yRef = y - 175
			local index = math.floor(yRef/75)
			local remainder = yRef % 75
			if index < 1 or index > #pauseMenu.buttons or remainder > 50 then
				return InGame
			end
			local selection = pauseMenu.buttons[index]

			if selection == "Save" then
				typingSaveName = true
			elseif selection == "Load" then
				return LoadGameMenu
			elseif selection == "Quit" then
				love.event.quit()
			end
		else
			return InGame
		end
	end

	if debugmode == true then
		Debug.mousepressed(x, y, button, mouseWorldX, mouseWorldY)
	end
end

function InGame.mousereleased(x, y, button)
	players[1].cursorX = x
	players[1].cursorY = y
	players[1]:mousereleased(button)

	if debugmode == true then
		Debug.mousereleased(x, y, button, mouseWorldX, mouseWorldY)
	end

	return InGame
end

return InGame

local Debug = require("debugTools")
local Gamesave = require("gamesave")
local SceneParser = require("sceneParser")
local Screen = require("screen")
local Utf8 = require("utf8")
local Util = require("util")
local Menu = require("menu")
local LocationTable = require("locationTable")

local GameState = require("gamestates/gameState")
local InGame = GameState()

local paused = false
local debugmode = false
local eventTime = 0
local second = 0

local menuOpen = false
local pauseMenu = {}
pauseMenu.buttons = {"Save", "Main Menu", "Quit"}

local menu
if love.graphics then
	pauseMenu.font = love.graphics.newFont(18)
	menu = Menu.create(love.graphics.getWidth() / 2, 225, 5, pauseMenu.buttons)
end

local typingSaveName = false
local saveName = ""

local world, players, screen
function InGame.load(...)
	world, players, screen = ...

	Debug.setWorld(world)
	Debug.setPlayers(players)
end

function InGame.resize(w, h)
	Screen:arrange(w, h)
end

function InGame.textinput(key)
	if typingSaveName then
		if key:match("^%w$") then
			saveName = saveName .. key
		end
	end
end

function InGame.keypressed(key)
	if key == "f12" then debugmode = not debugmode end

	if typingSaveName then
		if key == "backspace" then
			-- The string is utf-8 encoded, so the last character of the string
			-- could be multiple bytes.
			local byteoffset = Utf8.offset(saveName, -1)
			if byteoffset then
				saveName = saveName:sub(1, byteoffset - 1)
			end
		elseif key == "return" then
			typingSaveName = false
		elseif key == "escape" then
			saveName = ""
			typingSaveName = false
		end
	else
		for _, player in ipairs(players) do
			player:buttonpressed(love.keyboard, key)
		end

		if key == "p" or key == "pause" then
			paused = not paused
		end
	end

	if debugmode then
		Debug.keyboard(key)
	end

	return InGame
end

function InGame.keyreleased(key)
	if not typingSaveName then
		for _, player in ipairs(players) do
			player:buttonreleased(love.keyboard, key)
		end
	end
end

function InGame.mousepressed(x, y, button)
	if not typingSaveName then
		for _, player in ipairs(players) do
			player:buttonpressed(love.mouse, button)
		end
	end

	if menuOpen then
		if button == 1 then
			local index = menu:getButtonAt(x, y)
			local selection = pauseMenu.buttons[index]

			if selection == "Save" then
				typingSaveName = true
			elseif selection == "Main Menu" then
				menuOpen = false
				InGame.stackQueue:pop()
			elseif selection == "Quit" then
				love.event.quit()
			end
		end
	end

	if debugmode then
		Debug.mousepressed(x, y, button)
	end
end

function InGame.mousereleased(x, y, button)
	for _, player in ipairs(players) do
		player:buttonreleased(love.mouse, button)
	end

	if debugmode then
		Debug.mousereleased(x, y, button)
	end
end

function InGame.joystickpressed(joystick, button)
	for _, player in ipairs(players) do
		player:buttonpressed(joystick, button)
	end
end

function InGame.joystickreleased(joystick, button)
	for _, player in ipairs(players) do
		player:buttonreleased(joystick, button)
	end
end

function InGame.wheelmoved(_, y) --(x, y)
	for _, player in ipairs(players) do
		if y > 0 then
			player:buttonpressed(love.mouse, "yWheel")
		elseif y < 0 then
			player:buttonpressed(love.mouse, "-yWheel")
		end
	end
end

function InGame.update(dt)
	local openMenu, closeMenu = false, false
	-- Send input to the players.
	for _, player in ipairs(players) do
		openMenu  = openMenu  or player.openMenu
		player.openMenu  = false
		closeMenu = closeMenu or player.closeMenu
		player.closeMenu = false
		player.menuOpen = menuOpen

		player:handleInput()
	end

	if closeMenu then
		menuOpen = false
	elseif openMenu then
		menuOpen = true
	end

	if not (paused or menuOpen) then
		world:update(dt)

		eventTime = eventTime + dt
		second = second + dt
		if second > 1 then

			for _, player in ipairs(players) do
				if player.ship then
					local timeVar = 1 - 50/(20 + eventTime)
					if timeVar < 0 then timeVar = 0 end
					local disVar = 1 - 50/(1 + Util.vectorMagnitude(
								player.ship.body:getX(),player.ship.body:getY())/20)
					if disVar < 0 then disVar = 0 end
					local veloVar = 1 - 50/(1 + Util.vectorMagnitude(
								player.ship.body:getLinearVelocity()))
					if veloVar < 0 then veloVar = 0 end
					local rand = love.math.random()
					if rand < timeVar * disVar * veloVar or
							(debugmode and Debug.getSpawn()) then
						eventTime = 0
						local scene = math.ceil(love.math.random() * 10)
						scene = tostring(scene)
						local location = {player.ship.body:getX(),
										  player.ship.body:getY()}
						local vV = {player.ship.body:getLinearVelocity()}
						local mag = Util.vectorMagnitude(unpack(vV))
						local uV
						if mag ~= 0 then
							uV = {vV[1]/mag , vV[2]/ mag}
						else
							uV = {0, 1}
						end
						local pV = {-uV[2], uV[1]}
						local r = 2 * (math.random() - 0.5)
						local m = 1000 / player.camera.zoom
						if m < 100 then m = 100 end
						local netV = {m * (uV[1] + r * pV[1]),
									  m * (uV[2] + r * pV[2])}
						location[1] = location[1] + netV[1]
						location[2] = location[2] + netV[2]
						location[3] = 2 * math.pi * math.random()

						location = LocationTable(unpack(location))
						local inputs = {playerTeam = 1, playerShip = player.ship}
						local ships = SceneParser.loadScene("scene" .. scene, world, location, inputs)
						for _, ship in ipairs(ships) do
							world:addObject(ship)
						end
					end
				end
			end
			second = second - 1
		end
	end

	-- Save the game.
	if not typingSaveName and #saveName > 0 then
		local ok, message = Gamesave.save(saveName, world)
		if not ok then
			print("Failed to save the game: " .. message)
		end

		saveName = ""
	end

	if debugmode then Debug.update(dt) end
end

function InGame.draw()
	local screen_width = love.graphics.getWidth()

	for _, player in ipairs(players) do
		player:draw()
	end
	love.graphics.origin()

	if paused then
		love.graphics.print("Paused", screen_width/2-24, 30)
	end
	if menuOpen then
		menu:draw()
	end
	if typingSaveName then
		love.graphics.print("Type a name to use for your save, then press enter:", screen_width/2-150, 60)
		love.graphics.print(saveName, screen_width/2-150, 90)
	end

	-- Print debug info.
	if debugmode then Debug.draw() end
end

return InGame

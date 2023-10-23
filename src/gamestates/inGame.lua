local Controls = require("controls")
local Debug = require("debugmode")
local Log = require("log")
local Menu = require("menu")
local Player = require("player")
local SaveMenu = require("saveMenu")
local SceneParser = require("sceneParser")
local Screen = require("screen")
local Settings = require("settings")
local World = require("world/world")
local console = require("console")
local lume = require("vendor/lume")
local vector = require("vector")

local GameState = require("gamestates/gameState")
local InGame = GameState()

local paused = false
local eventTime = 0
local second = 0

local menuOpen = false
local pauseMenu = {}
pauseMenu.buttons = {"Save", "Main Menu", "Quit"}

local function pauseMenuAction(selection, back)
	local action = pauseMenu.buttons[selection]
	if action == "Save" then
		menuOpen = "Save"
	elseif action == "Main Menu" then
		menuOpen = false
		InGame.stackQueue:pop()
	elseif action == "Quit" then
		love.event.quit()
	end

	if back then menuOpen = false end
end

local menu = Menu.create(225, 5, pauseMenu.buttons)

local world, players, screen, saveMenu, debugmode, log
function InGame.load(scene, playerHostility, saveName)
	if saveName then
		for line in scene do
			local match = string.match(line, "teamhostility = (.*)")
			if match then
				playerHostility = lume.deserialize(match, true)
			elseif string.match(line, "%[scene%]") then
				break
			end
		end
	end

	world = World(playerHostility)

	screen = Screen()

	local playerShips, maxTeam = SceneParser.loadScene(scene, world, {0,0,0,0,0,0})
	-- TODO: Instead of creating players here, we should create one
	-- player per controller when the game starts up and pass those
	-- players into the world here.
	players = {}
	for i, ship in ipairs(playerShips) do
		if i == 1 then
			table.insert(
				players,
				Player.create(world, Controls(), ship, screen:createCamera())
			)
		else
			local joystick = love.joystick.getJoysticks()[#players]
			if joystick then
				table.insert(
					players,
					Player.create(world, Controls(joystick), ship, screen:createCamera())
				)
			end
		end
	end

	-- Reastablish collisions and
	world.physics:update(0)

	if #players == 0 then
		table.insert(players, Player.create(world, Controls(), nil, screen:createCamera()))
	end

	saveMenu = SaveMenu(Settings.saveDir, saveName)
	debugmode = Debug.create(world, players)
	log = Log(debugmode)
	console.init({
		players = players,
		world = world,
		debugmode = debugmode,
		quit = love.event.quit
	})
end

function InGame.resize(w, h)
	screen:arrange(w, h)
end

function InGame.textinput(key)
	if menuOpen == "Save" then
		saveMenu:textinput(key)
	end
end

function InGame.keypressed(key)
	if key == "f12" then debugmode.on = not debugmode.on end

	if menuOpen == "Pause" then
		pauseMenuAction(menu:keypressed(key))
	elseif menuOpen == "Save" then
		if key == "return" then
			local ok, message = saveMenu:saveFile(SceneParser.saveScene(world))
			if not ok then
				log.error("Failed to save the game: " .. message)
			end
			menuOpen = false
		else
			saveMenu:keypressed(key)
		end
	else
		for _, player in ipairs(players) do
			player:buttonpressed(love.keyboard, key, debugmode.on)
		end

		if key == "p" or key == "pause" then
			paused = not paused
		end

		if debugmode.on then
			debugmode:keyboard(key)
		end
	end

	return InGame
end

function InGame.keyreleased(key)
	if not menuOpen then
		for _, player in ipairs(players) do
			player:buttonreleased(love.keyboard, key)
		end
	end
end

function InGame.mousepressed(x, y, button)
	if menuOpen == "Pause" then
		if button == 1 then
			pauseMenuAction(menu:getButtonAt(x, y))
		end
	else
		for _, player in ipairs(players) do
			player:buttonpressed(love.mouse, button)
		end

		if debugmode.on then
			debugmode:mousepressed(x, y, button)
		end
	end
end

function InGame.mousereleased(x, y, button)
	for _, player in ipairs(players) do
		player:buttonreleased(love.mouse, button)
	end

	if debugmode.on then
		debugmode:mousereleased(x, y, button)
	end
end

function InGame.mousemoved(x, y)
	menu:mousemoved(x, y)
end

function InGame.joystickreleased(joystick, button)
	for _, player in ipairs(players) do
		player:buttonreleased(joystick, button)
	end
end

function InGame.gamepadpressed(joystick, button)
	for _, player in ipairs(players) do
		player:buttonpressed(joystick, button)
	end

	if menuOpen == "Pause" then
		pauseMenuAction(menu:gamepadpressed(button))
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
	console.repl(dt)

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
		menuOpen = "Pause"
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
					local disVar = 1 - 50/(1 + vector.magnitude(
								player.ship.body:getX(),player.ship.body:getY())/20)
					if disVar < 0 then disVar = 0 end
					local veloVar = 1 - 50/(1 + vector.magnitude(
								player.ship.body:getLinearVelocity()))
					if veloVar < 0 then veloVar = 0 end

					local rand = love.math.random()
					local product = timeVar * disVar * veloVar

					log:debug("Spawn roll: %s < %s ? %s",
						rand,
						product,
						{timeVar=timeVar, disVar=disVar, veloVar=veloVar}
					)

					if rand < product or
							(debugmode.on and debugmode:getSpawn()) then
						eventTime = 0
						local scene = math.ceil(love.math.random() * 10)
						scene = tostring(scene)
						local location = {
							player.ship.body:getX(), player.ship.body:getY(),
							0, 0, 0, 0
							}

						local vV = {player.ship.body:getLinearVelocity()}
						local mag = vector.magnitude(unpack(vV))
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

						local inputs = {playerTeam = 1, playerShip = player.ship}
						local ships = SceneParser.loadScene("scene" .. scene, world, location, inputs)
						for _, ship in ipairs(ships) do
							world:addObject(ship)
						end
						log:info("Spawned scene " .. scene)
					end
				end
			end
			second = second - 1
		end
	end

	if debugmode.on then debugmode:update(dt) end
end

function InGame.draw()
	local screen_width = love.graphics.getWidth()

	for _, player in ipairs(players) do
		player:draw(debugmode.on)
	end
	love.graphics.origin()

	if paused then
		love.graphics.print("Paused", screen_width/2-24, 30)
	end
	if menuOpen == "Pause" then
		menu:draw()
	elseif menuOpen == "Save" then
		saveMenu:draw()
	end

	-- Print debug info.
	if debugmode.on then debugmode:draw() end
end

return InGame

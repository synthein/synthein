local Menu = require("menu")
local PartSelector = require("partSelector")

local GameState = require("gamestates/gameState")
local ShipEditor = GameState()

local buttonNames = {"Main Menu", "Quit"}
ShipEditor.menu = Menu.create(350, 5, buttonNames)
ShipEditor.partSelector = PartSelector.create(50, 5, {"Test"})

function ShipEditor.update(dt)
	ShipEditor.menu:update(dt)
end

function ShipEditor.draw()
	ShipEditor.menu:draw()
	ShipEditor.partSelector:draw()
	love.graphics.print("wsad: Move around\n" ..
						"qe: Rotate Part\n",
						5, 5)
end

function ShipEditor.keypressed(key)
	if key == "escape" then
		ShipEditor.stackQueue:pop()
	end

	local button = ShipEditor.menu:keypressed(key)
	ShipEditor.testButton(button)
end

function ShipEditor.mousepressed(x, y, mouseButton)
	local button = ShipEditor.menu:pressed(x, y)
	if mouseButton == 1 then
		ShipEditor.testButton(button)
	end
end

function ShipEditor.testButton(button)
	local scene, playerHostility
	local start = true
	if button == "Single Player" then
		scene = "startScene"
		playerHostility = {{false}}
	elseif button == "COOP" then
		scene = "startSceneCOOP"
		playerHostility = {{false, false}, {false, false}}
	elseif button == "Allied" then
		scene = "startSceneTwoPlayer"
		playerHostility = {{false, false}, {false, false}}
	elseif button == "VS" then
		scene = "startSceneTwoPlayer"
		playerHostility = {{false, true}, {true, false}}
	else
		start = false
	end

	if start then
		local callList = ShipEditor.stackQueue:replace(InitWorld)
		callList.load(scene, playerHostility, false)
	end
end

function ShipEditor.resize(w, h)
	ShipEditor.menu:resize(w, h)
end

function ShipEditor.mousemoved(x, y)
	ShipEditor.menu:mousemoved(x, y)
end

function ShipEditor.wheelmoved(x, y)
	ShipEditor.menu:wheelmoved(x, y)
end

return ShipEditor

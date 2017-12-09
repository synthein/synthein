local GameState = {}
GameState.__index = GameState

function GameState.setStack(stack)
	GameState.stack = stack
end

function GameState.stackPop()
	table.remove(GameState.stack, #GameState.stack)
end

function GameState.stackPush(state)
	table.insert(GameState.stack, state)
end

function GameState.stackReplace(state)
	GameState.stackPop()
	GameState.stackPush(state)
end

function GameState.update()
end

function GameState.draw()
end

function GameState.keypressed()
end

function GameState.keyreleased()
end

function GameState.mousepressed()
end

function GameState.mousereleased()
end

function GameState.joystickpressed()
end

function GameState.joystickreleased()
end

function GameState.mousemoved()
end

function GameState.wheelmoved()
end

function GameState.textinput()
end

function GameState.resize()
end

return GameState

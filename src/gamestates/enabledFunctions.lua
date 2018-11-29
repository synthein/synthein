local enabledFunctionNames =
{
	"load",
	"resize",
	"keypressed",
	"keyreleased",
	"mousemoved",
	"mousepressed",
	"mousereleased",
	"joystickpressed",
	"joystickreleased",
	"textinput",
	"resize",
	"wheelmoved",
	"update",
	"draw"
}

local function emptyFunction() end

local enabledFunctions = {}

for _, v in ipairs(enabledFunctionNames) do
	enabledFunctions[v] = emptyFunction
end

return enabledFunctions

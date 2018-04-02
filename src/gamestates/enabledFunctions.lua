local functionKeys =
{
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

local enabledFunctions = {}

for _, v in ipairs(functionKeys) do
	enabledFunctions[v] = true
end

return enabledFunctions

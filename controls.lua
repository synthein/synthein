local Controls = {}

local keyboard = love.keyboard
local getJoysticks = love.joystick.getJoysticks

function Controls.isDown(control)
	return control[1].isDown(control[2])
end

function Controls.order(control)
	return control[3]
end

Controls.defaults = {
	keyboard = {
		ship = {
			{keyboard, "w", "forward"},
			{keyboard, "s", "back"},
			{keyboard, "a", "left"},
			{keyboard, "d", "right"},
			{keyboard, "q", "strafeLeft"},
			{keyboard, "e", "strafeRight"},
			{keyboard, "space", "shoot"}
		},
		confirm		= {keyboard, "return"},
		cancel		= {keyboard, "escape"}
	},
	gamepad = {
		ship = {
			{getJoysticks()[1], "dpup", "forward"},
			{getJoysticks()[1], "dpdown", "back"},
			{getJoysticks()[1], "dpleft", "left"},
			{getJoysticks()[1], "dpright", "right"},
			{getJoysticks()[1], "leftshoulder", "strafeLeft"},
			{getJoysticks()[1], "rightshoulder", "strafeRight"},
			{getJoysticks()[1], "a", "shoot"}
		},
		confirm		= {getJoysticks()[1], "a"},
		cancel		= {getJoysticks()[1], "b"}
	}
}

return Controls

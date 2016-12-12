local Controls = {}

Controls.defaults = {
	keyboard = {
		forward = "w",
		back = "s",
		left = "a",
		right = "d",
		strafeLeft = "q",
		strafeRight = "e",
		confirm = "return",
		cancel = "escape",
		shoot = "space"
	},
	gamepad = {
		joystick = love.joystick.getJoysticks()[1],
		forward = "dpup",
		back = "dpdown",
		left = "dpleft",
		right = "dpright",
		strafeLeft = "leftshoulder",
		strafeRight = "rightshoulder",
		confirm = "a",
		cancel = "b",
		shoot = "a"
	}
}

return Controls

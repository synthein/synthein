local Controls = {}

local mouse = love.mouse
local keyboard = love.keyboard
local getJoysticks = love.joystick.getJoysticks

function Controls.test(control, source, button)
	return control[1] == source and control[2] == button
end

function Controls.isDown(control)
	return control[1].isDown(control[2])
end

function Controls.order(control)
	return control[3]
end

Controls.defaults = {
	keyboard = {
		ship = {
			forward = {keyboard, "w", "forward"},
			back = {keyboard, "s", "back"},
			left = {keyboard, "a", "left"},
			right = {keyboard, "d", "right"},
			strafeLeft = {keyboard, "q", "strafeLeft"},
			strafeRight = {keyboard, "e", "strafeRight"},
			shoot = {keyboard, "space", "shoot"}
		},
		pressed = {
			build = {mouse, 1, "build"},
			destroy = {mouse, 2, "destroy"}
		},
		released = {
			build = {mouse, 1, "build"}
		},
		confirm		= {keyboard, "return"},
		cancel		= {keyboard, "escape"}
	},
	gamepad = {
		ship = {
			forward = {getJoysticks()[1], "dpup", "forward"},
			back = {getJoysticks()[1], "dpdown", "back"},
			left = {getJoysticks()[1], "dpleft", "left"},
			right = {getJoysticks()[1], "dpright", "right"},
			strafeLeft = {getJoysticks()[1], "leftshoulder", "strafeLeft"},
			strafeRight = {getJoysticks()[1], "rightshoulder", "strafeRight"},
			shoot = {getJoysticks()[1], "a", "shoot"}
		},
		pressed = {
		},
		released = {
		},
		confirm		= {getJoysticks()[1], "a"},
		cancel		= {getJoysticks()[1], "b"}
	}
}

return Controls

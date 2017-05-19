local Controls = {}

local mouse = love.mouse
local keyboard = love.keyboard
local getJoysticks = love.joystick.getJoysticks

function Controls.getOrders(controls)
	local orders = {}
	for key, order in pairs(Controls.shipCommands) do
		if Controls.isDown(controls[key]) then
			table.insert(orders, order)
		end
	end
	return orders
end

function Controls.testPressed(controls, source, button)
	for key, value in pairs(Controls.pressed) do
		local control = controls[key]
		if control[1] == source and control[2] == button then
			return value
		end
	end
end

function Controls.testReleased(controls, source, button)
	for key, value in pairs(Controls.pressed) do
		local control = controls[key]
		if control[1] == source and control[2] == button then
			return value
		end
	end
end

function Controls.setCursor(control, Cursor)
	local cursorChange
	if control[2] == "xAxis" then
		cursorChange = control[1].getX()
	elseif control[2] == "yAxis" then
		cursorChange = control[1].getY()
	else
		cursorChange = control[1].getAxis(control[2])
	end
	
	if control[3] == "set" then
		return cursorChange
	elseif control[3] == "change" then
		return cursorChange + Cursor
	end
end

function Controls.isDown(control)
	return control[1].isDown(control[2])
end

Controls.shipCommands = {
	forward 	= "forward",
	back    	= "back",
	left    	= "left",
	right   	= "right",
	strafeLeft	= "strafeLeft",
	strafeRight	= "strafeRight",
	shoot   	= "shoot"
}

Controls.pressed = {
	build   	= "build",
	destroy 	= "destroy",
	zoomOut		= "zoomOut",
	zoomIn		= "zoomIn"
}

Controls.released = {
	build   	= "build"
}

Controls.defaults = {
	keyboard = {
		forward 	= {keyboard, "w"},
		back    	= {keyboard, "s"},
		left    	= {keyboard, "a"},
		right   	= {keyboard, "d"},
		strafeLeft	= {keyboard, "q"},
		strafeRight	= {keyboard, "e"},
		shoot   	= {keyboard, "space"},
		build   	= {mouse, 1},
		destroy 	= {mouse, 2},
		zoomOut		= {mouse, "-yWheel"},
		zoomIn		= {mouse, "yWheel"},
		cursorX 	= {mouse, "xAxis", "set"},
		cursorY 	= {mouse, "yAxis", "set"},
		confirm		= {keyboard, "return"},
		cancel		= {keyboard, "escape"}
	},
	gamepad = {
		forward 	= {getJoysticks()[1], "dpup"},
		back    	= {getJoysticks()[1], "dpdown"},
		left    	= {getJoysticks()[1], "dpleft"},
		right   	= {getJoysticks()[1], "dpright"},
		strafeLeft	= {getJoysticks()[1], "leftshoulder"},
		strafeRight	= {getJoysticks()[1], "rightshoulder"},
		shoot   	= {getJoysticks()[1], "a"},
		build   	= {getJoysticks()[1], "y"},
		destroy 	= {getJoysticks()[1], "x"},
		cursorX 	= {getJoysticks()[1], 1, "change"},
		cursorY 	= {getJoysticks()[1], 2, "change"},
		confirm		= {getJoysticks()[1], "a"},
		cancel		= {getJoysticks()[1], "b"}
	}
}

return Controls

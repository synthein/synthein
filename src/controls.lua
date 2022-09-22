local Controls = {}

local mouse = love.mouse
local keyboard = love.keyboard

function Controls.getOrders(controls)
	local orders = {}
	for key, order in pairs(Controls.shipCommands) do
		if Controls.isDown(controls[key]) then
			table.insert(orders, order)
		end
	end
	return orders
end

function Controls.test(mode, controls, source, button)
	for key, value in pairs(Controls[mode]) do
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
		cursorChange = control[1]:getAxis(control[2])
	end

	if control[3] == "set" then
		return cursorChange
	elseif control[3] == "change" then
		return cursorChange + Cursor
	end
end

function Controls.isDown(control)
	if control[1].isGamepad and control[1]:isGamepad() then
		return control[1]:isGamepadDown(control[2])
	else
		return control[1].isDown(control[2])
	end
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
	playerMenu  = "playerMenu",
	build   	= "build",
	destroy 	= "destroy",
	zoomOut		= "zoomOut",
	zoomIn		= "zoomIn"
}

Controls.released = {
	build   	= "build"
}

Controls.menu = {
	confirm    = "confirm",
	cancel     = "cancel",
	playerMenu = "playerMenu",
}

function Controls.defaults(joystick)
	if joystick then
		return {
			forward 	= {joystick, "dpup"},
			back    	= {joystick, "dpdown"},
			left    	= {joystick, "dpleft"},
			right   	= {joystick, "dpright"},
			strafeLeft	= {joystick, "leftshoulder"},
			strafeRight	= {joystick, "rightshoulder"},
			shoot   	= {joystick, "a"},
			build   	= {joystick, "b"},
			destroy 	= {joystick, "x"},
			playerMenu      = {joystick, "start"},
			zoomOut		= {mouse, "-yWheel"},
			zoomIn		= {mouse, "yWheel"},
			cursorX 	= {joystick, 1, "change"},
			cursorY 	= {joystick, 2, "change"},
			confirm		= {joystick, "a"},
			cancel		= {joystick, "b"}
			}
	else
		return {
			forward 	= {keyboard, "w"},
			back    	= {keyboard, "s"},
			left    	= {keyboard, "a"},
			right   	= {keyboard, "d"},
			strafeLeft	= {keyboard, "q"},
			strafeRight	= {keyboard, "e"},
			shoot   	= {keyboard, "space"},
			build   	= {mouse, 1},
			destroy 	= {mouse, 2},
			playerMenu  = {keyboard, "i"},
			zoomOut		= {mouse, "-yWheel"},
			zoomIn		= {mouse, "yWheel"},
			cursorX 	= {mouse, "xAxis", "set"},
			cursorY 	= {mouse, "yAxis", "set"},
			confirm		= {mouse, 1},
			cancel		= {keyboard, "escape"}
			}
	end
end

return Controls

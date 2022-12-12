local Controls = {}

local Log = require("log")

local log = Log({on = true})
local mouse = love.mouse
local keyboard = love.keyboard

local bindingsFile = "config/bindings.lua"

-- TODO: We probably want to organize this file as a class with methods?

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

function Controls.create(joystick)
	local bindings
	if joystick then
		bindings = {
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
		bindings = {
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

	local ok, chunk, err = pcall(love.filesystem.load, bindingsFile)
	if not ok then
		log:error("Failed to read key bindings: %s", chunk)
		return bindings
	end
	if not chunk then
		if string.match(err, "Does not exist.$") then
			log:debug("Failed to load key bindings file: %s", err)
		else
			log:error("Failed to load key bindings file: %s", err)
		end

		return bindings
	end

	ok, result = pcall(chunk)
	if not ok then
		log:error("Failed to read key bindings: %s", result)
		return bindings
	end
	if type(result) ~= "table" then
		log:error("Failed to read key bindings: \"%s\" is not a table", result)
		return bindings
	end

	for bind in pairs(bindings) do
		local newVal = result[bind]
		if newVal then
			log:debug("Binding %s to %s", bind, newVal)
			bindings[bind][2] = newVal
		end
	end

	return bindings
end

return Controls

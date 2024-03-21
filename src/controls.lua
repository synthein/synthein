local Log = require("log")

local log = Log()
local mouse = love.mouse
local keyboard = love.keyboard

local Controls = class()

local bindingsFile = "config/bindings.lua"

function Controls:getOrders()
	local orders = {}
	for key, order in pairs(Controls.shipCommands) do
		if Controls.isDown(self.bindings[key]) then
			table.insert(orders, order)
		end
	end
	return orders
end

function Controls:test(mode, source, button)
	for key, value in pairs(Controls[mode]) do
		local control = self.bindings[key]
		if control and control[1] == source and control[2] == button then
			return value
		end
	end
end

function Controls:getCursorPosition(oldX, oldY)
	local device = self.bindings.cursor[1]
	local stick = self.bindings.cursor[2]

	if device == mouse then
		return device.getPosition()
	else
		local xChange = device:getGamepadAxis(stick .. "x")
		local yChange = device:getGamepadAxis(stick .. "y")

		return oldX + xChange, oldY + yChange
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
	up         = "menuUp",
	down       = "menuDown",
	left       = "menuLeft",
	right      = "menuRight",
	confirm    = "confirm",
	cancel     = "cancel",
	playerMenu = "playerMenu",
}

--TODO Bundle Comands that have the same mapping let the widgets separated them out.

function Controls:__create(joystick)
	local bindings
	if joystick then
		self.bindings = {
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
			cursor		= {joystick, "left"},
			menuUp 	    = {joystick, "dpup"},
			menuDown    = {joystick, "dpdown"},
			menuLeft    = {joystick, "dpleft"},
			menuRight   = {joystick, "dpright"},
			confirm		= {joystick, "a"},
			cancel		= {joystick, "b"}
		}
	else
		self.bindings = {
			forward 	= {keyboard, "w"},
			back    	= {keyboard, "s"},
			left    	= {keyboard, "a"},
			right   	= {keyboard, "d"},
			strafeLeft	= {keyboard, "q"},
			strafeRight	= {keyboard, "e"},
			shoot   	= {keyboard, "space"},
			build   	= {mouse, 1},
			destroy 	= {mouse, 2},
			playerMenu	= {keyboard, "i"},
			zoomOut		= {mouse, "-yWheel"},
			zoomIn		= {mouse, "yWheel"},
			cursor		= {mouse},
			menuUp 	    = {keyboard, "w"},
			menuDown    = {keyboard, "s"},
			menuLeft    = {keyboard, "a"},
			menuRight   = {keyboard, "d"},
			confirm		= {mouse, 1},
			cancel		= {keyboard, "escape"}
		}
	end

	local ok, chunk, err = pcall(love.filesystem.load, bindingsFile)
	if not ok then
		log:error("Failed to read key bindings: %s", chunk)
		return
	end
	if not chunk then
		if string.match(err, "Does not exist.$") then
			log:debug("Failed to load key bindings file: %s", err)
		else
			log:error("Failed to load key bindings file: %s", err)
		end

		return
	end

	ok, result = pcall(chunk)
	if not ok then
		log:error("Failed to read key bindings: %s", result)
		return
	end
	if type(result) ~= "table" then
		log:error("Failed to read key bindings: \"%s\" is not a table", result)
		return
	end

	for bind in pairs(self.bindings) do
		local newVal = result[bind]
		if newVal then
			log:debug("Binding %s to %s", bind, newVal)
			self.bindings[bind][2] = newVal
		end
	end
end

Controls.map = {mouse = {}, keyboard = {}, joysticks = {}}

function Controls.loadDefaultMap()
	for i = 1,love.joystick.getJoystickCount() do
		local player = i + 1
		local joystickMap = {}
		joystickMap.buttons = {
			dpup          = {player = player, ship = "forward",     editor = "up",        menu = "up"     },
			dpdown        = {player = player, ship = "backward",    editor = "down",      menu = "down"   },
			dpleft        = {player = player, ship = "left",        editor = "left",      menu = "left"   },
			dpright       = {player = player, ship = "right",       editor = "right",     menu = "right"  },
			leftshoulder  = {player = player, ship = "strafeLeft",  editor = "ccw",       menu = nil      },
			rightshoulder = {player = player, ship = "strafeRight", editor = "cw",        menu = nil      },
			a             = {player = player, ship = "shoot",       editor = "add",       menu = "confirm"},
			b             = {player = player, ship = "build",       editor = "remove",    menu = "cancel" },
			x             = {player = player, ship = "destroy",     editor = "pallet",    menu = nil      },
			y             = {player = player, ship = "playerMenu",  editor = nil,         menu = "cancel" },
			start         = {player = player, ship = "gameMenu",    editor = "stateMenu", menu = "cancel" },
		}
		
		joystickMap.axis = {
			left = {player = player, ship = "cursor", editor = nil, menu = nil}
		}
		
		table.insert(Controls.map.joysticks, joystickMap)
	end
	
	Controls.map.keyboard = {
		w      = {player = 1, ship = "forward",      editor = "up",        menu = "up"     },
		s      = {player = 1, ship = "backward",     editor = "down",      menu = "down"   },
		a      = {player = 1, ship = "left",         editor = "left",      menu = "left"   },
		d      = {player = 1, ship = "right",        editor = "right",     menu = "right"  },
		q      = {player = 1, ship = "strafeLeft",   editor = "ccw",       menu = nil      },
		e      = {player = 1, ship = "strafeRight",  editor = "cw",        menu = nil      },
		i      = {player = 1, ship = "playerMenu",   editor = nil,         menu = nil      },
		f      = {player = 1, ship = nil,            editor = "pallet",    menu = nil      },
		r      = {player = 1, ship = nil,            editor = "remove",    menu = nil      },
		h      = {player = 1, ship = "health",       editor = nil,         menu = nil      },
		p      = {player = 1, ship = "pause",        editor = nil,         menu = nil      },
		f5     = {player = 1, ship = "cameraRotate", editor = nil,         menu = nil      },
		space  = {player = 1, ship = "shoot",        editor = "add",       menu = nil      },
		escape = {player = 1, ship = "gameMenu",     editor = "stateMenu", menu = "cancel" },
		f11    = {player = 1, ship = "fullsceen",    editor = nil,         menu = nil      },
		f12    = {player = 1, ship = "debug",        editor = nil,         menu = nil      },
	}
	
	Controls.map.keyboard["return"] = {player = 1, ship = nil, editor = nil, menu = "confirm"}
	
	Controls.map.mouse = {
		buttons = {
			{player = 1, ship = "build",    editor = "add",    menu = "confirm"},
			{player = 1, ship = "destroy",  editor = "remove", menu = nil      },
		},
		cursor = {player = 1, ship = "cursor",  editor = "cursor", menu = nil},
		wheel = {player = 1, ship = "zoom",     editor = "zoom",   menu = "scroll"}
	}
end

function Controls.lookupKey(key)
	return Controls.map.keyboard[key]
end

function Controls.lookupJoystickButton(joystick, button)
	local id = joystick:getID()
	return Controls.map.joysticks[id].buttons[button]
end

function Controls.lookupJoystickAxis(joystick, axis)
	local id = joystick:getID()
	return Controls.map.joysticks[id].axis[axis]
end

function Controls.lookupMouseButton(button)
	return Controls.map.mouse.buttons[button]
end

function Controls.lookupMouseCursor()
	return Controls.map.mouse.cursor
end

function Controls.lookupMouseWheel()
	return Controls.map.mouse.wheel
end

--TODO gamepads ???

return Controls

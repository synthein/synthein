function love.conf(t)
	t.identity = "synthein"
	t.version = "11.4"
	t.console = true

	t.window.title = "Synthein - Draw Times"
	t.window.icon = "tools.png"
	t.window.width = 800
	t.window.height = 600
	t.window.borderless = false
	t.window.resizable = false
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"
	t.window.vsync = true
end

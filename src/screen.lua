local ViewPort = require("viewPort")

local Screen = class()

function Screen:__create()
	self.viewPorts = {}
end

function Screen:createViewPort()
	local newViewPort = ViewPort()
	table.insert(self.viewPorts, newViewPort)
	self:arrange(love.graphics.getWidth(), love.graphics.getHeight())
	return newViewPort
end

function Screen:arrange(screenWidth, screenHeight)
	local n = #self.viewPorts
	local columns, rows = 1, 1
	for i = 1, n do
		if i > columns * rows then
			if screenWidth / columns > screenHeight / rows then
				columns = columns + 1
			else
				rows = rows + 1
			end
		end
	end

	if columns > rows then
		columns = math.min(columns, math.ceil(n / rows))
	else
		rows = math.min(rows, math.ceil(n / columns))
	end

	local viewPortWidth  = math.floor(screenWidth/columns)
	local viewPortHeight = math.floor(screenHeight/rows)
	for i, viewPort in ipairs(self.viewPorts) do
		local x = (i-1)%columns
		local y = (i-x -1)/columns
		viewPort:setScissor(x*viewPortWidth, y*viewPortHeight,
						  viewPortWidth, viewPortHeight)
	end
end

return Screen

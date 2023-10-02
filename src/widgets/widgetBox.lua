



local function gernerateScaleTable(horRef, verRef, horOff, verOff)
	horRef = (horRef == "left") and 0 or (horRef == "right" ) and 1 or 0.5
	verRef = (verRef == "top" ) and 0 or (verRef == "bottom") and 1 or 0.5
	horOff = (horOff == "left") and 0 or (horOff == "right" ) and 1 or 0.5
	verOff = (verOff == "top" ) and 0 or (verOff == "bottom") and 1 or 0.5
	return {horRef, verRef, horOff, verOff}
end


local WidgetBox = class()

function WidgetBox:__create(width, height)
	self.dimensions = {width, height}
	self.widgets = {}
end

function WidgetBox:addWidget(widget, position, scaleTable)
	local frame = {}
	frame.widget = widget
	frame.postion = position
	frame.scaleTable = gernerateScaleTable(unpack(scaleTable))
	frame.visable = true
end

function WidgetBox:within(cursorX, cursorY)
	local width, height = self.unpack(self.dimensions)
	local i = 1
	local widgets = self.widgets
	
	return function()
		while(i <= #widgets)
			local frame = widgets[i]
			local widget = frame.widget
			local x, y = unpack(frame.postion)
			local horRef, verRef, horOff, verOff = unpack(frame.scaleTable)
		
			local x = curX - canX - desWidth  * horRef + srcWidth  * horOff
			local y = curY - canY - desHeight * verRef + srcHeight * verOff
			
			local within = 0 <= x and x <= srcWidth and 0 <= y and y <= srcWidth
			
			if within and frame.visable then
				return widget, x, y
			end
		end
		
		return nil --Iterater is done
	end
end

function WidgetBox:keypressed(key)
end

function WidgetBox:pressed()
end


--TODO this is just a sample function
function WidgetBox:mousemoved(cursorX, cursorY)
	for widget, x, y in self.within(cursorX, cursorY) do
		widget:mousemoved(x, y)
	end
end

function WidgetBox:wheelmoved(x, y)
end

function WidgetBox:update(dt)
	for _, frame in ipairs(self.widgets) then
		frame.widget:update(dt)
	end
end

function WidgetBox:Ressize()
end

function WidgetBox:draw()
	--TODO cursor information

	local width, height = unpack(self.dimensions)
	local canvas = love.graphics.newCanvas(width, height)
	
	for _, frame in ipairs(self.widgets) then
		if frame.visable then
			local widget = frame.widget
			local widgetCanvas = widget:draw()
			local x, y = unpack(frame.postion)
			local horRef, verRef, horOff, verOff = unpack(frame.scaleTable)
			
			x = x + width  * horRef
			y = y + height * verRef
		
			love.graphics.setCanvas(canvas)
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(self.textCanvas, x, y, 0, 1, 1, horOff, verOff)
		end
	end
	
	love.graphics.setCanvas()
	
	return canvas
end

return WidgetBox

local CanvasUtils = {}

function CanvasUtils.generateScaleTable(horRef, verRef, horOff, verOff)
	if     horRef == "left" then
		horRef = 0
	elseif horRef == "right" then
		horRef = 1
	else
		horRef = 0.5
	end

	if     verRef == "top" then
		verRef = 0
	elseif verRef == "bottom" then
		verRef = 1
	else
		verRef = 0.5
	end

	if     horOff == "left" then
		horOff = 0
	elseif horOff == "right" then
		horOff = 1
	else
		horOff = 0.5
	end

	if     verOff == "top" then
		verOff = 0
	elseif verOff == "bottom" then
		verOff = 1
	else
		verOff = 0.5
	end

	return {horRef, verRef, horOff, verOff}
end

function CanvasUtils.copyCanvas(source, x, y, scaleTable, color, destination)
	local horRef, verRef, horOff, verOff = unpack(scaleTable)
	love.graphics.setColor(unpack(color or {1, 1, 1}))

	local srcWidth, srcHeight = source:getDimensions()
	local desWidth, desHeight = (destination or love.window):getDimensions()

	love.graphics.setCanvas(destination)

	local x = x + desWidth  * horRef - srcWidth  * horOff
	local y = y + desHeight * verRef - srcHeight * verOff

	love.graphics.draw(source, x, y)

	love.graphics.setCanvas()
end

function CanvasUtils.isWithin(curX, curY, canX, canY, source, destination, scaleTable)
	local horRef, verRef, horOff, verOff = unpack(scaleTable)
	local srcWidth, srcHeight = source:getDimensions()
	local desWidth, desHeight = (destination or love.window):getDimensions()

	local x = curX - canX - desWidth  * horRef + srcWidth  * horOff
	local y = curY - canY - desHeight * verRef + srcHeight * verOff

	local within = 0 <= x and x <= srcWidth and 0 <= y and y <= srcWidth

	return within, x, y
end

return CanvasUtils

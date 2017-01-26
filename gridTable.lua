GridTable = {}
GridTable.__index = GridTable

function GridTable.create()
	local self = {}
	setmetatable(self, Structure)

	self = {
			{ {{},{},{}} },
			{ {{},{},{}} },
			{ {{},{},{}} }
		   }

	return self
end

function GridTable:index(x, y, set, clear)
	local xSignIndex, xMagIndex, ySignIndex, yMagIndex
	local aTable, bTable, cTable, object

	if x == 0 then
		xSignIndex = 2
		xMagIndex = 1
	elseif x < 0 then
		xSignIndex = 1
		xMagIndex = -x
	elseif x > 0 then
		xSignIndex = 3
		xMagIndex = x
	end

	if y == 0 then
		ySignIndex = 2
		yMagIndex = 1
	elseif x < 0 then
		ySignIndex = 1
		yMagIndex = -y
	elseif x > 0 then
		ySignIndex = 3
		yMagIndex = y
	end

	aTable = self[ySignIndex]
	bTable = aTable[yMagIndex]

	if not bTable then
		if set then
			for i = #aTable,yMagIndex do
				table.insert(aTable, {{},{},{}})
			end
		else
			return nil
		end
	end

	cTable = bTable[xSignIndex]
	object = cTable[xMagIndex]

	if object then
		if clear then
			bTable[xMagIndex] = {}
		else
			return object
		end
	else
		if set then
			for i = #cTable,(xMagIndex - 1) do
				table.insert(cTable, {})
			end
			table.insert(cTable, set)
		else
			return nil
		end
	end
end

function GridTable:loop(f, inputs)
	local outputs = {}
	for ySignIndex = 1,3 do
		local aTable = self[ySignIndex]
		local ySign = ySignIndex - 2

		for yMagIndex = 1,#aTable
			local bTable = aTable[yMagIndex]
			local y = ySign * yMagIndex

			for xSignIndex = 1,3 do
				local cTable = bTable[xSignIndex]
				local xSign = xSignIndex -2

				for xMagIndex = 1,#cTable
					local object = cTable[xMagIndex]
					local x = ySign * yMagIndex
					
					local output = f(object, inputs, x, y, xSign, ySign)
					table.insert(outputs, output)
				end
			end
		end
	end
	return outputs
end

return GridTable

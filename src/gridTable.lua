GridTable = {}
GridTable.__index = GridTable

function GridTable.create()
	local self = {}
	setmetatable(self, GridTable)

	self.core = {
				 { {{},{},{}} },
				 { {{},{},{}} },
				 { {{},{},{}} }
			    }

	return self
end

function GridTable:index(x, y, set, clear)
	local xSignIndex, xMagIndex, ySignIndex, yMagIndex
	local aTable, bTable, cTable, object

	if y == 0 then
		ySignIndex = 2
		yMagIndex = 1
	elseif y < 0 then
		ySignIndex = 1
		yMagIndex = -y
	elseif y > 0 then
		ySignIndex = 3
		yMagIndex = y
	end

	aTable = self.core[ySignIndex]
	bTable = aTable[yMagIndex]

	if not bTable then
		if set then
			for i = #aTable,yMagIndex do
				table.insert(aTable, {{},{},{}})
			end
			bTable = aTable[yMagIndex]
		else
			return nil
		end
	end
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

	cTable = bTable[xSignIndex]
	object = cTable[xMagIndex]

	if object then
		if clear then
			cTable[xMagIndex] = {}
		elseif set then
			cTable[xMagIndex] = set
		else
			return object
		end
	else
		if set then
			for i = (#cTable + 1), xMagIndex do
				if i == xMagIndex then
					table.insert(cTable, set)
				else
					table.insert(cTable, {})
				end
			end
		else
			return nil
		end
	end
end

function GridTable:loop(f, inputs)
	local outputs = {}
	for ySignIndex = 1,3 do
		local aTable = self.core[ySignIndex]
		local ySign = ySignIndex - 2

		for yMagIndex = 1,#aTable do
			local bTable = aTable[yMagIndex]
			local y = ySign * yMagIndex

			for xSignIndex = 1,3 do
				local cTable = bTable[xSignIndex]
				local xSign = xSignIndex -2

				for xMagIndex = 1,#cTable do
					local object = cTable[xMagIndex]
					local x = xSign * xMagIndex
					
					if next(object) then
						local output
						if f then
							output = f(object, inputs, x, y)
						else
							output = object
						end
						table.insert(outputs, output)
					end
				end
			end
		end
	end
	return outputs
end

return GridTable

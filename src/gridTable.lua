local GridTable = class()
GridTable.__index = GridTable
local Structure = class()

function GridTable:__create()
	self.core = {}
	local core = self.core
	for i = -1,1 do
		local newtable = {}
		for j = -1,1 do
			newtable[j] = {false}
		end
		core[i] = {newtable}
	end
end

local function toGTindex(index)
	local sign = index > 0 and 1 or index < 0 and -1 or 0
	local mag = sign * index
	return sign, mag ~= 0 and mag or 1
end

function GridTable:index(x, y, set, clear)
	local aTable, bTable, cTable, object

	local ySignIndex, yMagIndex = toGTindex(y)

	aTable = self.core[ySignIndex]
	bTable = aTable[yMagIndex]

	if not bTable then
		if set then
			for _ = (#aTable + 1), yMagIndex do
				local t = {}
				for i = -1,1 do
					t[i] = {false}
				end
				table.insert(aTable, t)
			end
			bTable = aTable[yMagIndex]
		else
			return nil
		end
	end

	local xSignIndex, xMagIndex = toGTindex(x)

	cTable = bTable[xSignIndex]
	object = cTable[xMagIndex]

	if object ~= nil then
		if clear then
			cTable[xMagIndex] = false
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
					if cTable ~= nil then
						table.insert(cTable, false)
					end
				end
			end
		else
			return nil
		end
	end
end

function GridTable:loop(f, inputs, addSelf)
	local outputs = {}
	for ySignIndex = -1,1 do
		local aTable = self.core[ySignIndex]
		local ySign = ySignIndex

		for yMagIndex = 1,#aTable do
			local bTable = aTable[yMagIndex]
			local y = ySign * yMagIndex

			for xSignIndex = -1,1 do
				local cTable = bTable[xSignIndex]
				local xSign = xSignIndex

				for xMagIndex = 1,#cTable do
					local object = cTable[xMagIndex]
					local x = xSign * xMagIndex

					if object then
						local output
						if f then
							if type(f) == "function" then
								output = f(object, inputs, x, y)
							elseif type(f) == "string" then
								if object[f] then
									if addSelf then
										object[f](object, unpack(inputs))
									else
										object[f](unpack(inputs))
									end
								end
							else
								return {}
							end
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

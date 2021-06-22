local CallList = {}
CallList.__index = CallList

function CallList.create(reference, options)
	local self = {}
	setmetatable(self, CallList)

	-- The table that these functions will be called on or a function that
	-- returns said table.
	self.reference = reference

	-- Options
		-- isObject
			--Set to true if reference is a object.
		-- objectTypeString
			-- String for the error message. Error is ignored if nil
		-- returnInformation
			-- Value or reference returned each time a call is added or a
			-- function that generates a new value or reference for each call.
		-- update
			-- Function that is called after processing each call.
	for k, v in pairs(options) do
		self[k] = v
	end

	local returnInformation = self.returnInformation
	self.returnInformation = nil

	local addIndex = function(t, key)
		return CallList.addIndex(t, key, returnInformation)
	end

	self.list = setmetatable({}, {__index = addIndex})

	return self
end

function CallList.addIndex(t, key, returnInformation)
	local updateInformation
	if type(returnInformation) == "function" then
		returnInformation, updateInformation = returnInformation()
	end

	local info = debug.getinfo(2)

	local codeLocation = info.short_src .. ":" .. info.currentline ..
						 ":"-- in function '" .. name .. "'"

	local reference = {key, nil, updateInformation, codeLocation}
	table.insert(t, reference)
	return function(...)
		reference[2] = {...}
		return returnInformation
	end
end

function CallList:process()
	local list = self.list
	local reference = self.reference
	local objectTypeString = self.objectTypeString
	local update = self.update

	if type(reference) == "function" then
		reference = reference()
	end

	for i, call in ipairs(list) do
		list[i] = nil
		local key, inputs, updateInformation, codeLocation = unpack(call, 1, 4)
		-- Get the function
		local f = reference[key]
		if not f then
			if objectTypeString then
				local message = "There is no function called '" ..
								tostring(key) .. "' in " .. objectTypeString ..
								"."
				if codeLocation then
					message = message .. "\n\nCheck\n\n" .. codeLocation
				end
				error(message)
			end
		else
			if self.isObject then
				inputs[1] = reference
			end

			local returnValue = f(unpack(inputs))

			if update then
				update(reference, returnValue, updateInformation)
			end
		end
	end
end

return CallList

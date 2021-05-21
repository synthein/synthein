local Stack = require("stack")
local CallList = require("callList")

-- The purpose for the stack manager it to prevent circular referencing when
-- using stacks.
local StackManager = {}
StackManager.__index = StackManager

-- Creates a managed stack and returns a reference to the current state.
function StackManager.create(initialState, indexValue)
	local self = {}
	setmetatable(self, StackManager)

	self.indexValue = indexValue
	self.stack = Stack.create()
	self:createQueue(initialState)

	return self:createCurrentStateReference()
end

function StackManager:createQueue(initialState)
	local currentState = function()
		return self.stack:peek()
	end

	local createStateCallList = function()
		local options = {objectTypeString = "gameState"}
		local callList = CallList.create(currentState, options)
		return callList.list, callList
	end

	local options = {}
	options.isObject = true
	options.objectTypeString = "a stack"
	options.returnInformation = createStateCallList
	options.update = function(reference, removedState, updateInformation)
		local state = reference:peek()
		-- Set stackQueue for the new state and delete it for the old state.
		state[self.indexValue] = self.queue.list
		if removedState then
			removedState.stackQueue = nil
		end

		updateInformation:process()
	end

	self.queue = CallList.create(self.stack, options)

	self.queue.list:push(initialState)
	self:processQueue()
end

function StackManager:createCurrentStateReference()
	-- Function that is called when the state is referenced
	local f = function(t, key)
		-- Function that collects the requested function from the current state
		-- and manages the queue after function is called.
		return function(...)
			local returnValue = self.stack:peek()[key](...)
			self:processQueue()
			return returnValue
		end
	end

	-- Return a table that acts like the current state by calling the prior
	-- function when indexed.
	return setmetatable({}, {__index = f})
end

function StackManager:processQueue()
	self.queue:process()
end

return StackManager


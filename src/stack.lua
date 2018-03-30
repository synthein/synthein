local Stack = {}
Stack.__index = Stack

function Stack.create()
	local self = {}
	setmetatable(self, Stack)

	return self
end

function Stack:pop()
	return table.remove(self, #self)
end

function Stack:push(state)
	table.insert(self, state)
end

function Stack:replace(state)
	local pop = self:pop()
	self:push(state)
	return pop
end

function Stack:peek()
	return self[#self]
end

return Stack

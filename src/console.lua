local reader = love.thread.newThread("consolereader.lua")
local input = love.thread.newChannel()
reader:start(input)

local console = {}
local env = {
	print = print,
	table = table,
}

function console.init(state)
	for k, v in pairs(state) do
		env[k] = v
	end
end

function console.repl()
	local line = input:pop()
	if line then
		local code, err = load(line, "stdin", "t", env)
		if not code then
			print(err)
		else
			-- The first return value from pcall is whether the
			-- function had an error or not. The remaining values
			-- are either an error message or the return values
			-- of the function. We don't currently use the first
			-- return value. We print errors or results for the
			-- user to see.
			local results = {select(2, pcall(code))}
			if #results > 0 then
				print(unpack(results))
			end
		end
	end
end

return console

local reader = love.thread.newThread("consolereader.lua")
local input = love.thread.newChannel()
local done = love.thread.newChannel()
reader:start(input, done)

local console = {
	sleeptime = 0,
}
local env = {
	print = print,
	table = table,
	sleep = function(n)
		console.sleeptime = n
	end,
}

function console.init(state)
	for k, v in pairs(state) do
		env[k] = v
	end
end

function console.repl(dt)
	local line

	if console.sleeptime > 0 then
		console.sleeptime = console.sleeptime - dt
	else
		line = input:pop()
	end

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

function console.quit()
	done:push(true)
end

return console

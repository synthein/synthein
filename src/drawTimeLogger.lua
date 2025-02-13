local log = require("log")

local DrawTimeLogger = {}

function DrawTimeLogger.create(capacity, logdir, logfile)
  local self = {}
	setmetatable(self, {__index = DrawTimeLogger})

  self.times = {}
  self.capacity = capacity
  self.frameCount = 0

	local err
  self.logfile, err = love.filesystem.newFile(logfile, "w")
	if err then
		log:error("failed to open draw time log file: %s", err)
	end

  return self
end

function DrawTimeLogger:insert(duration)
	if #self.times == self.capacity then
		table.remove(self.times, 1)
	end

	table.insert(self.times, duration)
end

local interval = 30
function DrawTimeLogger:log()
	self.frameCount = self.frameCount + 1

	if self.frameCount % interval == 0 then
		local ok, err = self.logfile:write(
			table.concat(self.times, "\n", #self.times-interval + 1, #self.times) .. "\n"
		)
		if not ok then
			log:error("failed to log draw times: %s", err)
		end
	end
end

function DrawTimeLogger:average()
	local sum = 0
	local count = 0

	for i, t in ipairs(self.times) do
		sum = sum + t
		count = i
	end

	return sum / count
end

return DrawTimeLogger

local DrawTimeLogger = {}

function DrawTimeLogger.create(capacity, logfile)
  local self = {}
	setmetatable(self, {__index = DrawTimeLogger})

  self.times = {}
  self.capacity = capacity
  self.frameCount = 0
  self.logfile = logfile
  love.filesystem.write(logfile, "")

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
		love.filesystem.append(
			self.logfile,
			table.concat(self.times, "\n", #self.times-interval + 1, #self.times) .. "\n"
		)
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

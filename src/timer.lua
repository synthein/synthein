local Timer = class()

function Timer:__create(limit)
  self.limit = limit
  self.currentTime = limit
end

function Timer:ready(dt)
  local time = self.currentTime - dt
  self.currentTime = time

  if time <= 0 then
    self.currentTime = self.currentTime + self.limit
    return true
  else
    return false
  end
end

function Timer:time(time)
	if time then
		self.currentTime = time
	end

	return self.currentTime
end

return Timer

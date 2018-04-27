local Timer = class()

function Timer:__create(limit)
  self.limit = limit
  self.currentTime = limit
end

function Timer:ready(dt)
  self.currentTime = self.currentTime - dt

  if self.currentTime < 0 then
    print(self.currentTime)
    self.currentTime = self.currentTime + self.limit
    return true
  else
    return false
  end
end

return Timer

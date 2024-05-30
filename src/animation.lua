local Animation = class()

local funcs = {}
function funcs.linear(s, d, r) return (d-s)*r + s end

function Animation:__create(start, dest, duration, func)
  self.start = start
  self.dest = dest
  self.elapsed = 0
  self.duration = duration
  self.func = funcs[func]
end

function Animation:step(dt, dest)
  if dest then
    self.dest = dest
  end

  self.elapsed = self.elapsed + dt

  local x = self.func(self.start[1], self.dest[1], self.elapsed / self.duration)
  local y = self.func(self.start[2], self.dest[2], self.elapsed / self.duration)
  local a = self.func(self.start[3], self.dest[3], self.elapsed / self.duration)

  return x, y, a
end

function Animation:isDone()
  return self.elapsed >= self.duration
end

return Animation

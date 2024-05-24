
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

function Animation:step(dt)
  self.elapsed = self.elapsed + dt
  return self.func(self.start, self.dest, self.elapsed / self.duration)
end

function Animation:isDone()
  return self.elapsed >= self.duration
end

return Animation

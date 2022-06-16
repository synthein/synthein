return function()
  local stub = {}
  return setmetatable(stub, {
    __index = function() return stub end,
    __call = function() return stub, stub end,
    __sub = function() return 1 end,
    __div = function() return 1 end,
  })
end

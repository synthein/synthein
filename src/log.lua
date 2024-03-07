local Settings = require("settings")

local Log = class()

function Log:__create()
end

local function texpand(t)
  local str = "{"
  local num_items = 0
  for k, v in pairs(t) do
    if num_items > 0 then
      str = str .. ", "
    end
    num_items = num_items + 1

    str = str .. string.format("%s = %s", k, v)
  end
  return str .. "}"
end

local function out(message, ...)
  local processed = {}

  for i=1,select('#', ...) do
    local oldval = select(i, ...)
    local newval

    if type(oldval) == "table" then
      newval = texpand(oldval)
    elseif type(oldval) == "nil" then
      newval = "nil"
    else
      newval = oldval
    end

    processed[i] = newval
  end
  io.stderr:write(os.date() .. " " .. string.format(message, unpack(processed)) .. "\n")
end

function Log:error(message, ...)
  out("ERR " .. message, ...)
end

function Log:info(message, ...)
  out("INFO " .. message, ...)
end

function Log:debug(message, ...)
  if Settings.debug then out("DEBUG " .. message, ...) end
end

return Log

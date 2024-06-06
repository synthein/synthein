local Settings = require("settings")

local Log = class()

function Log:__create()
end

Log.levels = {
  ERROR = 1,
  WARN  = 2,
  INFO  = 3,
  DEBUG = 4
}

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

local function out(minimumSeverity, message, ...)
  if Log.levels[Settings.logLevel] < minimumSeverity then
    return
  end

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
  out(1, "ERROR " .. message, ...)
end

function Log:warn(message, ...)
  out(2, "WARN  " .. message, ...)
end

function Log:info(message, ...)
  out(3, "INFO  " .. message, ...)
end

function Log:debug(message, ...)
  out(4, "DEBUG " .. message, ...)
end

return Log

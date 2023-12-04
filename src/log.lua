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
  for i, v in pairs({...}) do
    processed[i] = type(v) == "table" and texpand(v) or v
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

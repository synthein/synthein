local Log = class()

function Log:__create(debugmode)
  self.debugmode = debugmode
end

local function texpand(t)
  local str
  for k, v in pairs(t) do
    if str == nil then
      str = "{"
    else
      str = str .. ", "
    end

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
  if self.debugmode.on then out("DEBUG " .. message, ...) end
end

return Log

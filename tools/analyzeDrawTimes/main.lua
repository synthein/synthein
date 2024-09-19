-- Settings
local logfile = "draw-times.log"
local margin = 30
local nBuckets = 20

-- State
local lastLoad = 0
local times = {}
local max = 0
local min = math.huge

local function reload()
  times = {}
  max = 0
  min = math.huge

  for time in love.filesystem.lines(logfile) do
    local time = tonumber(time)
    table.insert(times, time)
    max = math.max(max, time)
    min = math.min(min, time)
  end
end

function love.load()
end

function love.update(dt)
  local info = love.filesystem.getInfo(logfile)

  if info.modtime > lastLoad then
    reload()
    lastLoad = info.modtime
  end
end

function love.draw()
  local chartWidth = love.graphics.getWidth() - margin
  local chartHeight = love.graphics.getHeight() - margin

  local buckets = {}
  for _, v in ipairs(times) do
    local bucketIndex = 1 + math.floor((v - min) / (max - min) * (nBuckets-1))
    local oldCount = buckets[bucketIndex] or 0
    buckets[bucketIndex] = oldCount + 1
  end

  local tallestBar = 0
  for i = 1, nBuckets do
    tallestBar = math.max(tallestBar, buckets[i] or 0)
  end

  local font = love.graphics.getFont()
  for i = 1, nBuckets do
    local v = buckets[i] or 0
    local w = chartWidth / nBuckets
    local h = v / tallestBar * (chartHeight - margin)
    local x = margin + (i-1)*w
    love.graphics.rectangle("fill", x, chartHeight, w, -h)

    local label = tostring(tonumber(v))
    local textWidth = font:getWidth(label)
    love.graphics.print(label, x + (w - textWidth)/2, chartHeight-h-20)
  end
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
end

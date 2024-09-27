-- Settings
local logfile = "draw-times.log"
local margin = 50
local nBuckets = 20

-- State
local lastLoad = 0
local times = {}
local max
local font = love.graphics.setNewFont(10)

local function reload()
  times = {}
  max = 0

  for time in love.filesystem.lines(logfile) do
    local time = tonumber(time)
    table.insert(times, time)
    max = math.max(max, time)
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
  local chartWidth = love.graphics.getWidth() - margin * 2
  local chartHeight = love.graphics.getHeight() - margin * 2

  love.graphics.print("Number of frames", 10, love.graphics.getHeight()/2, -math.pi/2)
  love.graphics.print("Duration of frame (ms)", love.graphics.getWidth()/2, love.graphics.getHeight() - 20)

  local buckets = {}
  for _, v in ipairs(times) do
    local bucketIndex = math.ceil(v / max * nBuckets)
    local oldCount = buckets[bucketIndex] or 0
    buckets[bucketIndex] = oldCount + 1
  end

  local tallestBar = 0
  for i = 1, nBuckets do
    tallestBar = math.max(tallestBar, buckets[i] or 0)
  end

  -- Draw bars
  for i = 1, nBuckets do
    local v = buckets[i] or 0
    local w = chartWidth / nBuckets
    local h = v / tallestBar * chartHeight
    local x = margin + (i-1)*w
    local y = margin + chartHeight

    love.graphics.rectangle("fill", x, y, w, -h)

    local label = tostring(tonumber(v))
    local textWidth = font:getWidth(label)
    love.graphics.print(label, x + (w - textWidth)/2, y-h-20)

  end

  -- Draw tick marks
  for i = 0, nBuckets do
    local w = chartWidth / nBuckets
    local x = margin + i * w
    local y = margin + chartHeight
    local label = string.format("%0.1f", i*max/nBuckets*1000)
    local textWidth = font:getWidth(label)

    love.graphics.line(x, y, x, y+10)
    love.graphics.print(label, x - textWidth/2, y+10)
  end
end

function love.keypressed(key)
	if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
end

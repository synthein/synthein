-- Settings
local logfile = "draw-times.log"
local margin = 50
local nBuckets = 20

-- State
local lastLoad = 0
local times = {}
local nTimes
local max
local font = love.graphics.setNewFont(10)
local percentilesFont = love.graphics.newFont(16)

local function reload()
  times = {}
  nTimes = 0
  max = 0

  for time in love.filesystem.lines(logfile) do
    local time = tonumber(time)
    table.insert(times, time)
    nTimes = nTimes + 1
    max = math.max(max, time)
  end
end

local function bucketLowerBound(bucketIndex)
  assert(bucketIndex >= 1)
  return (bucketIndex - 1) * max / nBuckets
end

local function bucketUpperBound(bucketIndex)
  assert(bucketIndex <= nBuckets)
  return bucketIndex * max / nBuckets
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

  for i = 1, nBuckets do
    buckets[i] = 0
  end

  for _, v in ipairs(times) do
    local bucketIndex = math.ceil(v / max * nBuckets)
    local oldCount = buckets[bucketIndex] or 0
    buckets[bucketIndex] = oldCount + 1
  end

  -- Calculate statistics
  --- We don't have a sorted list of all times, only the count in each bucket,
  --- so the percision of these percentiles is limited by the number of buckets.
  local heightOfTallestBar = 0
  local passedTimes = 0
  local median = 0
  local p95 = 0
  local p99 = 0
  for i, samplesInBucket in ipairs(buckets) do
    heightOfTallestBar = math.max(heightOfTallestBar, samplesInBucket)
    passedTimes = passedTimes + (buckets[i] or 0)
    if (median == 0) and (passedTimes > nTimes * 0.50) then
      median = bucketLowerBound(i)
    end
    if (p95 == 0) and (passedTimes > nTimes * 0.95) then
      p95 = bucketLowerBound(i)
    end
    if (p99 == 0) and (passedTimes > nTimes * 0.99) then
      p99 = bucketLowerBound(i)
    end
  end

  -- Draw bars
  for i = 1, nBuckets do
    local v = buckets[i] or 0
    local w = chartWidth / nBuckets
    local h = v / heightOfTallestBar * chartHeight
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
    local label = string.format("%.1f", bucketUpperBound(i) * 1000)
    local textWidth = font:getWidth(label)

    love.graphics.line(x, y, x, y + 10)
    love.graphics.print(label, x - textWidth / 2, y + 10)
  end

  -- Draw percentiles
  local percentiles = {
    { label = "median", time = median },
    { label = "p95", time = p95 },
    { label = "p99", time = p99 },
  }

  for i, data in ipairs(percentiles) do
    local text = string.format("%s    %.1f", data.label, data.time * 1000)
    love.graphics.print(text,
      percentilesFont,
      margin + chartWidth - percentilesFont:getWidth(text),
      margin + (i - 1) * percentilesFont:getHeight(text)
    )
    end
end

function love.keypressed(key)
  if key == "f11" then love.window.setFullscreen(not love.window.getFullscreen(), "desktop") end
end

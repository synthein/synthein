local lunatest = require("vendor/lunatest")

for _, file in ipairs(love.filesystem.getDirectoryItems("tests")) do
  modname = file:match("^(test_.*)%.lua$")
  if modname then
    lunatest.suite("tests." .. modname)
  end
end

lunatest.run()

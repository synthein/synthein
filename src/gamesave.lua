local SceneParser = require("sceneParser")

local Gamesave = {}
local saveDir = "saves/"

-- Gamesave.save: Save the game to a file.
-- Returns boolean success status and (optionally) a message explaining why
-- there was a failure.
function Gamesave.save(saveName, world)
	local fileString = SceneParser.saveScene(world)

	if not love.filesystem.isDirectory(saveDir) then
		local ok = love.filesystem.createDirectory(saveDir)
		if not ok then
			return false, "Failed to create save directory."
		end
	end

	return love.filesystem.write(saveDir .. saveName .. ".txt", fileString)
end

return Gamesave

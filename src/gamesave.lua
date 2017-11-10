local SceneParser = require("sceneParser")

local Gamesave = {}
local saveDir = "saves/"

-- Gamesave.load: Load a game from a file.
-- Returns an iterator for the lines in a save file on success.
-- Returns nil and a reason why on failure.
function Gamesave.load(saveName)
	local fileName = saveDir .. saveName .. ".txt"

	if not love.filesystem.isFile(fileName) then
		return nil, string.format("File %s does not exist", fileName)
	end

	return love.filesystem.lines(fileName)
end

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

local SceneParser = require("sceneParser")
local Settings = require("settings")

local Gamesave = {}

-- Gamesave.load: Load a game from a file.
-- Returns an iterator for the lines in a save file on success.
-- Returns nil and a reason why on failure.
function Gamesave.load(saveName)
	local fileName = Settings.saveDir .. saveName .. ".txt"

	if not love.filesystem.getInfo(fileName, "file") then
		return nil, string.format("File %s does not exist", fileName)
	end

	return love.filesystem.lines(fileName)
end

-- Gamesave.save: Save the game to a file.
-- Returns boolean success status and (optionally) a message explaining why
-- there was a failure.
function Gamesave.save(saveName, world)
	if saveName == "" then
		return false, "save name cannot be empty"
	end

	local fileContents = SceneParser.saveScene(world)

	if not love.filesystem.getInfo(Settings.saveDir, "directory") then
		local ok = love.filesystem.createDirectory(Settings.saveDir)
		if not ok then
			return false, "failed to create save directory"
		end
	end

	return love.filesystem.write(Settings.saveDir .. saveName .. ".txt", fileContents)
end

return Gamesave

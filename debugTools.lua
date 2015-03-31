local Block = require("block")
local Engine = require("engine")
local Gun = require("gun")
local Structure = require("structure")

local Debug = {}

function Debug.keyboard(key, globalOffsetX, globalOffsetY)
	-- Spawn a block
	if key == "u" then
		table.insert(worldStructures,
		Structure.create(Block.create(), world,
		globalOffsetX + 50, globalOffsetY - 100))
	end
	-- Spawn an engine
	if key == "i" then
		table.insert(worldStructures,
		Structure.create(Engine.create(), world,
		globalOffsetX + 112, globalOffsetY))
	end
	-- Spawn a gun
	if key == "o" then
		table.insert(worldStructures,
		Structure.create(Gun.create(), world,
		globalOffsetX + 50, globalOffsetY + 100))
	end
end

function Debug.mouse(globalOffsetX, globalOffsetY)
	if love.mouse.isDown("m") then
		mouseX, mouseY = love.mouse.getPosition()

		if not Debug.mouseJoint then
			for i, structure in ipairs(worldStructures) do
				for j, part in ipairs(structure.parts) do
					local partX, partY = structure:getAbsPartCoords(j)

					if (mouseX - SCREEN_WIDTH/2 + globalOffsetX) < (partX + part.width/2) and
					   (mouseX - SCREEN_WIDTH/2 + globalOffsetX) > (partX - part.width/2) and
					   (mouseY - SCREEN_HEIGHT/2 + globalOffsetY) < (partY + part.height/2) and
					   (mouseY - SCREEN_HEIGHT/2 + globalOffsetY) > (partY - part.height/2) then
						Debug.mouseJoint = love.physics.newMouseJoint(
							structure.body, mouseX - SCREEN_WIDTH/2 + globalOffsetX, mouseY - SCREEN_HEIGHT/2 + globalOffsetY)
						break
					end
				end
				if Debug.mouseJoint then break end
			end
		else
			Debug.mouseJoint:setTarget(mouseX - SCREEN_WIDTH/2 + globalOffsetX, mouseY - SCREEN_HEIGHT/2 + globalOffsetY)
		end

	elseif Debug.mouseJoint then
		Debug.mouseJoint:destroy()
		Debug.mouseJoint = nil
	end
end

return Debug

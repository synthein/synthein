-- Discuss


-- General Concepts:
	-- Check annex permistions
		-- Other structure approval
			-- This is only relavent in hacker prevention not relavent in single instance
			-- Server might be able to verify this.
		-- Approval can be gained before things are flagged
			-- Builders can keep a list of valid sources and destinations
	-- Add parts to receving structure with the relavent vectors
		-- What parts are valid to connect
		-- Break off parts that don't fit
	-- Flag recieving structure to be unrecemptive to build commands
	-- Flag giving structure to be unrecemptive to build commands
		-- or remove parts
	-- On recieving structure update add new parts clear flag
	-- Moving into positon during Annex or before Annex
		-- During
			-- Requires the annex to exist for a period of time
			-- Would interact with the physics
				-- 180 rotational lock problem.
			-- More difficult to know which parts have valid connections.
			-- Needs to properly abort if it can't move into place.
		-- Before annex requires more advanced user interface.
			-- Some setups May reintroduce the rotational lock problem


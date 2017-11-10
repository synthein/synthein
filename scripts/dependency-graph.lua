#!/usr/bin/env lua
-- dependency-graph.lua by Jordan Christiansen, 2017
--
-- To the extent possible under law, Jordan Christiansen has waived all
-- copyright and related or neighboring rights to dependency-graph.lua. For
-- more information, see: https://creativecommons.org/publicdomain/zero/1.0/
--
-- To render the dot output, install graphviz (http://www.graphviz.org/) and
-- use the `dot` command.

function printUsage()
	print('Usage: dependency-graph.lua [--text | --dot] [ROOT_FILE]')
	print('If ROOT_FILE is unspecified, main.lua will be used.')
end

function main(arg)
	local dot
	local rootFile
	for i, option in ipairs(arg) do
		if option == '--text' then
			dot = false
		elseif option == '--dot' then
			dot = true
		else
			if rootFile == nil then
				rootFile = string.gsub(option, '%.lua$', '')
			else
				print('Unrecognized argument: ' .. option)
				printUsage()
				os.exit(1)
			end
		end
	end

	if rootFile == nil then
		rootFile = 'main'
	end

	local dir, file
	if string.match(rootFile, '/') then
		dir, file = string.match(rootFile, '(.*/)([^/]*)$')
	else
		dir = ''
		file = rootFile
	end

	local dependencies = {}
	getDeps(file, dir, dependencies)
	if dot then
		renderDot(dependencies)
	else
		renderText(dependencies)
	end
end

function getDeps(filename, dir, depsTable)
	if depsTable[filename] ~= nil then
		return
	end
	depsTable[filename] = {}

	local f = io.open(dir .. filename .. '.lua')
	if f == nil then
		io.stderr:write('File not found: ' .. dir .. filename .. '.lua\n')
		return
	end

	for line in f:lines() do
		requiredFile = string.match(line, 'require%("([%w/]+)"%)')
		if requiredFile ~= nil then
			table.insert(depsTable[filename], requiredFile)
			getDeps(requiredFile, dir, depsTable)
		end
	end
	f:close()
end

function renderText(dependencies)
	for k, v in pairs(dependencies) do
		if #v >= 1 then
			print(string.format('%s has %d dependencies:', k, #v))
			for i, dep in ipairs(v) do
				print('\t' .. dep)
			end
		end
	end
end

function renderDot(dependencies)
	print('digraph {')
	print('\trankdir="LR";')
	print('\tnode [shape=box];')

	for parent, deps in pairs(dependencies) do
		if #deps >= 1 then
			for i, dep in ipairs(deps) do
				print(string.format('\t"%s" -> "%s";', parent, dep))
			end
		end
	end

	print('}')
end

main(arg)

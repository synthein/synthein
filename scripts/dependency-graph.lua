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
	print('Usage: dependency-graph.lua [--text | --dot] [--dir ROOT_DIR] [ROOT_FILE]')
	print('If ROOT_FILE is unspecified, main.lua will be used.')
end

function main(args)
	local dot
	local dir, file
	local skip
	for i, arg in ipairs(args) do
		if skip then
			skip = false
		else
			if arg == '--text' then
				dot = false
			elseif arg == '--dot' then
				dot = true
			elseif arg == '--dir' then
				dir = args[i+1]
				skip = true
			else
				if file == nil then
					file = string.gsub(arg, '%.lua$', '')
				else
					print('Unrecognized argument: ' .. arg)
					printUsage()
					os.exit(1)
				end
			end
		end
	end

	file = file or 'main'

	if dir then
		if not string.match(dir, '/$') then
			dir = dir .. '/'
		end
	else
		if string.match(file, '/') then
			dir, file = string.match(file, '(.*/)([^/]*)$')
		else
			dir = './'
		end
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
	sortedKeys = sortKeys(dependencies)
	for _, module in ipairs(sortedKeys) do
		deps = dependencies[module]
		if #deps >= 1 then
			print(string.format('%s has %d dependencies:', module, #deps))
			for i, dep in ipairs(deps) do
				print('\t' .. dep)
			end
		end
	end
end

function renderDot(dependencies)
	print('digraph {')
	print('\trankdir="LR";')
	print('\tnode [shape=box];')

	sortedKeys = sortKeys(dependencies)
	for _, module in ipairs(sortedKeys) do
		deps = dependencies[module]
		if #deps >= 1 then
			for i, dep in ipairs(deps) do
				print(string.format('\t"%s" -> "%s";', module, dep))
			end
		end
	end

	print('}')
end

function sortKeys(t)
	keys = {}

	for k in pairs(t) do
		table.insert(keys, k)
	end

	table.sort(keys)
	return keys
end

main(arg)

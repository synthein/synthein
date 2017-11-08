#!/usr/bin/env lua
-- dependency-graph.lua by Jordan Christiansen, 2017
--
-- To the extent possible under law, Jordan Christiansen has waived all
-- copyright and related or neighboring rights to dependency-graph.lua. For
-- more information, see: https://creativecommons.org/publicdomain/zero/1.0/
--
-- To run this script, you must install graphviz (http://www.graphviz.org/) and
-- LuaGRAPH (https://github.com/hleuwer/luagraph).

local graph = require("graph")

function printUsage()
	print("Usage: dependency-graph.lua [--text | --graph] [ROOT_FILE]")
	print("If ROOT_FILE is unspecified, main.lua will be used.")
end

function main(arg)
	local text
	local rootFile
	for i, option in ipairs(arg) do
		if option == "--text" then
			text = true
		elseif option == "--graph" then
			text = false
		else
			if rootFile == nil then
				rootFile = string.gsub(option, "%.lua$", "")
			else
				print("Unrecognized argument: " .. option)
				printUsage()
				os.exit(1)
			end
		end
	end

	if rootFile == nil then
		rootFile = "main"
	end

	local dir, file
	if string.match(rootFile, "/") then
		dir, file = string.match(rootFile, "(.*/)([^/]*)$")
	else
		dir = ""
		file = rootFile
	end

	local dependencies = {}
	getDeps(file, dir, dependencies)
	if text then
		renderText(dependencies)
	else
		renderGraph(dependencies)
	end
end

function getDeps(filename, dir, depsTable)
	if depsTable[filename] ~= nil then
		return
	end
	depsTable[filename] = {}

	local f = io.open(dir .. filename .. ".lua")
	if f == nil then
		print("File not found: " .. dir .. filename .. ".lua")
		return
	end

	for line in f:lines() do
		requiredFile = string.match(line, "require%(\"([%w/]+)\"%)")
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
			print(string.format("%s has %d dependencies:", k, #v))
			for i, dep in ipairs(v) do
				print("\t" .. dep)
			end
		end
	end
end

function renderGraph(dependencies)
	g = graph.open("G")
	g:declare{
		graph = {
			rankdir = "LR",
		},
		node = {
			shape = "box",
			width = 0,
			height = 0,
			margin = 0.03,
			fontsize = 12,
		},
		edge = {
			arrowsize = 1
		}
	}

	for k, v in pairs(dependencies) do
		local node = g:node(k)
		if #v >= 1 then
			for i, dep in ipairs(v) do
				node:edge(g:node(dep))
			end
		end
	end

	g:layout()
	g:render("png", "out.png")
	g:close()	
end

main(arg)

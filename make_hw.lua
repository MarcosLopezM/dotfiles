#!/usr/bin/env lua

local lfs = require("lfs")

local function parse_args()
	local args = { positional = {}, options = {} }

	for _, v in ipairs(arg) do
		if v:match("^%-%-") then
			local key, value = v:match("^%-%-(.-)=(.*)")
			if key and value then
				args.options[key] = value
			end
		else
			table.insert(args.positional, v)
		end
	end

	return args
end

-- Verify if a directory exists, if not create it
local function ensure_directory_exists(dir)
	local err, _ = lfs.attributes(dir, "mode")
	if not err then
		lfs.mkdir(dir)
	end
end

-- Create a specific number of files in a directory
local subfile_snippet = [[
\documentclass[../main.tex]{subfiles}

\begin{document}
    \begin{problema}
        \kant[%d]
    \end{problema}
\end{document}
]]

local function create_files_in_dir(dir, filename, num_files)
	ensure_directory_exists(dir)
	for i = 1, num_files do
		local file_path = string.format("%s/%s_%02d.tex", dir, filename, i)
		local file = io.open(file_path, "w")
		if file then
			file:write(subfile_snippet:format(i))
			file:close()
			print("Created file: " .. file_path)
		else
			print("Error creating file: " .. file_path)
		end
	end
end

local function write_metadata(main_file, metadata)
	for _, key in ipairs({
		"title",
		"author",
		"instructor",
		"duedate",
		"assignno",
		"group",
		"semester",
		"subject",
	}) do
		if metadata[key] then
			main_file:write(string.format("\\%s{%s}\n", key, metadata[key]))
		end
	end
end

local function create_main_tex(dir, filename, num_files, metadata)
	local main_file = io.open("main.tex", "w")
	if not main_file then
		print("Error: Cannot write main.tex")
		return
	end

	main_file:write([[
\documentclass[digital]{fc-hw-template}

]])

	write_metadata(main_file, metadata)

	main_file:write("\n\\begin{document}\n\\maketitle\n\n")

	for i = 1, num_files do
		local command = (i == 1) and "\\subfile" or "\\subfileinclude"
		local entry = string.format("  %s{%s/%s_%02d.tex}\n", command, dir, filename, i)
		main_file:write(entry)
	end

	main_file:write("\n\\end{document}\n")
	main_file:close()
	print("Created main.tex")
end

-- Parse args
local args = parse_args()
local dir = args.positional[1] or "exercises"
local filename = args.positional[2] or "exercise"
local num_files = tonumber(args.positional[3]) or 3

create_files_in_dir(dir, filename, num_files)
create_main_tex(dir, filename, num_files, args.options)

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

-- Create .gitignore file template
local function create_gitignore(mk_gitignore)
	local path = ".gitignore"

	if not mk_gitignore then
		return nil
	end

	local file = io.open(path, "r")
	if file then
		file:close()
		print(".gitignore already exists, skipping")
		return
	end

	local gitignore_template = [[
## Core latex/pdflatex auxiliary files:
*.aux
*.lof
*.log
*.lot
*.fls
*.out
*.toc
*.fmt
*.fot
*.cb
*.cb2
.*.lb

## Intermediate documents:
*.dvi
*.xdv
*-converted-to.*
# these rules might exclude image files for figures etc.
# *.ps
# *.eps
# *.pdf

## Generated if empty string is given at "Please type another file name for output:"
*.pdf

## Bibliography auxiliary files (bibtex/biblatex/biber):
*.bbl
*.bcf
*.blg
*-blx.aux
*-blx.bib
*.run.xml

## Build tool auxiliary files:
*.fdb_latexmk
*.synctex
*.synctex(busy)
*.synctex.gz
*.synctex.gz(busy)
*.pdfsync

## Build tool directories for auxiliary files
# latexrun
latex.out/

## Auxiliary and intermediate files from other packages:
# algorithms
*.alg
*.loa

# achemso
acs-*.bib

# amsthm
*.thm

# beamer
*.nav
*.pre
*.snm
*.vrb

# changes
*.soc

# comment
*.cut

# cprotect
*.cpt

# elsarticle (documentclass of Elsevier journals)
*.spl

# endnotes
*.ent

# fixme
*.lox

# feynmf/feynmp
*.mf
*.mp
*.t[1-9]
*.t[1-9][0-9]
*.tfm

#(r)(e)ledmac/(r)(e)ledpar
*.end
*.?end
*.[1-9]
*.[1-9][0-9]
*.[1-9][0-9][0-9]
*.[1-9]R
*.[1-9][0-9]R
*.[1-9][0-9][0-9]R
*.eledsec[1-9]
*.eledsec[1-9]R
*.eledsec[1-9][0-9]
*.eledsec[1-9][0-9]R
*.eledsec[1-9][0-9][0-9]
*.eledsec[1-9][0-9][0-9]R

# glossaries
*.acn
*.acr
*.glg
*.glo
*.gls
*.glsdefs
*.lzo
*.lzs
*.slg
*.slo
*.sls

# uncomment this for glossaries-extra (will ignore makeindex's style files!)
# *.ist

# gnuplot
*.gnuplot
*.table

# gnuplottex
*-gnuplottex-*

# gregoriotex
*.gaux
*.glog
*.gtex

# htlatex
*.4ct
*.4tc
*.idv
*.lg
*.trc
*.xref

# hyperref
*.brf

# knitr
*-concordance.tex
# TODO Uncomment the next line if you use knitr and want to ignore its generated tikz files
# *.tikz
*-tikzDictionary

# listings
*.lol

# luatexja-ruby
*.ltjruby

# makeidx
*.idx
*.ilg
*.ind

# minitoc
*.maf
*.mlf
*.mlt
*.mtc[0-9]*
*.slf[0-9]*
*.slt[0-9]*
*.stc[0-9]*

# minted
_minted*
*.pyg

# morewrites
*.mw

# newpax
*.newpax

# nomencl
*.nlg
*.nlo
*.nls

# pax
*.pax

# pdfpcnotes
*.pdfpc

# sagetex
*.sagetex.sage
*.sagetex.py
*.sagetex.scmd

# scrwfile
*.wrt

# svg
svg-inkscape/

# sympy
*.sout
*.sympy
sympy-plots-for-*.tex/

# pdfcomment
*.upa
*.upb

# pythontex
*.pytxcode
pythontex-files-*/

# tcolorbox
*.listing

# thmtools
*.loe

# TikZ & PGF
*.dpth
*.md5
*.auxlock

# titletoc
*.ptc

# todonotes
*.tdo

# vhistory
*.hst
*.ver

# easy-todo
*.lod

# xcolor
*.xcp

# xmpincl
*.xmpi

# xindy
*.xdy

# xypic precompiled matrices and outlines
*.xyc
*.xyd

# endfloat
*.ttt
*.fff

# Latexian
TSWLatexianTemp*

## Editors:
# WinEdt
*.bak
*.sav

# Texpad
.texpadtmp

# LyX
*.lyx~

# Kile
*.backup

# gummi
.*.swp

# KBibTeX
*~[0-9]*

# TeXnicCenter
*.tps

# auto folder when using emacs and auctex
./auto/*
*.el

# expex forward references with \gathertags
*-tags.tex

# standalone packages
*.sta

# Makeindex log files
*.lpz

# xwatermark package
*.xwm

# REVTeX puts footnotes in the bibliography by default, unless the nofootinbib
# option is specified. Footnotes are the stored in a file with suffix Notes.bib.
# Uncomment the next line to have this generated file ignored.
#*Notes.bib

# Python files
**/.venv

### JupyterNotebooks ###

.ipynb_checkpoints
*/.ipynb_checkpoints/*

# IPython
profile_default/
ipython_config.py

# Remove previous ipynb_checkpoints
#   git rm -r .ipynb_checkpoints/
]]

	file = io.open(path, "w")
	if file then
		file:write(gitignore_template)
		file:close()
		print("Created .gitignore")
	else
		print("Error: Cannot create .gitignore")
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
%! TeX program = lualatex
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
local make_gitignore = args.positional[4] == "true"

ensure_directory_exists("figs") -- Create a figs directory if it doesn't exist
create_gitignore(make_gitignore)
create_files_in_dir(dir, filename, num_files)
create_main_tex(dir, filename, num_files, args.options)

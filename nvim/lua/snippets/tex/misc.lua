local ls = require("luasnip")
local extras = require("luasnip.extras")
local events = require("luasnip.util.events")
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras").line_begin
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local m = extras.match
local d = ls.dynamic_node
local c = ls.choice_node
-- local conds = require("luasnip.extras.expand_conditions")
-- local make_condition = require("luasnip.extras.conditions").make_condition

-- Inside specific environment
local function env(name)
  local is_inside = vim.fn["vimtex#env#is_inside"](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end

-- Expand command
local function cmd(name)
  return vim.fn["vimtex#syntax#in"](name) == 1
end

-- Context table
local tex = {}

-- Math context
tex.in_mathzone = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

-- Class context
tex.in_class = function(class)
  return vim.b.vimtex.documentclass == class
end

-- File type context
tex.is_package_file = function()
  local ext = vim.fn.expand("%:e")
  return ext == "cls" or ext == "sty"
end

tex.is_standard_file = function()
  return vim.fn.expand("%:e") == "tex"
end

tex.is_bibliography_file = function()
  return vim.fn.expand("%:e") == "bib"
end

-- Plain text context
tex.in_text = function()
  return not tex.in_mathzone()
end

tex.in_preamble = function()
  return not env("document")
end

-- Comment detection
tex.in_comment = function() -- comment detection
  return vim.fn["vimtex#syntax#in_comment"]() == 1
end

-- Helper function to get visual selection
local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

local misc = {
  -- Id est
  s(
    {
      trig = "([,])ie",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      desc = "Id est",
    },
    fmta([[<> i.e. <>]], {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(0),
    }),
    { context = tex.in_text }
  ),

  -- Chapter/Section commands in markdown style
  s(
    {
      trig = "h(%d)",
      regTrig = true,
      wordTrig = false,
      desc = "Markdown style headers, i.e. h1, h2, h3",
      snippetType = "autosnippet",
    },
    fmta(
      [[
      \<>{<>}
      ]],
      {

        f(function(_, snip)
          local sub_str = "sub"
          local sec = "section"
          local chp = "chapter"
          local header_level = tonumber(snip.captures[1])

          if tex.in_class("book") or tex.in_class("tesisFCiencias") or tex.in_class("memoir") then
            if header_level == 1 then
              return chp
            else
              return string.rep(sub_str, header_level - 2) .. sec
            end
          end

          if tex.in_class("article") or tex.in_class("fc-hw-template") then
            return string.rep(sub_str, header_level - 1) .. sec
          end
        end),
        i(1),
      }
    ),
    {
      condition = tex.in_text,
    }
  ),

  -- Usepackage command
  s(
    {
      trig = "up",
      regTrig = false,
      desc = "Usepackage command for .tex files",
    },
    fmta([[ \usepackage{<>} ]], { i(1) }),
    {
      condition = function()
        return tex.in_preamble() and tex.is_standard_file()
      end,
    }
  ),
  s(
    {
      trig = "up",
      regTrig = false,
      desc = "RequirePackage command for .sty and .cls files",
    },
    fmta([[ \RequirePackage{<>} ]], { i(1) }),
    {
      condition = function()
        return tex.in_preamble() and tex.is_package_file()
      end,
    }
  ),

  -- Dummy text
  s(
    {
      trig = "k(%d)",
      regTrig = true,
      snippetType = "autosnippet",
      desc = "Add kantlipsum with specified paragrah",
    },
    fmta(
      [[
        \kant[<>]
      ]],
      {
        f(function(_, snip)
          return snip.captures[1]
        end),
      }
    ),
    { condition = tex.in_text }
  ),

  -- Generate label
  s(
    {
      trig = "(%a+):(%w+)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      desc = "Auto label fig:foo → \\label{fig:foo}",
    },
    fmta("\\label{<>:<><>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
      i(1),
    }),
    {
      condition = function()
        return (tex.in_text() or tex.in_mathzone())
          and not cmd("texRefArg")
          and not cmd("texZRefArg")
          and not tex.in_comment()
          and not tex.is_standard_file()
      end,
    }
  ),
  -- Quotes
  s(
    {
      trig = "qq",
      wordTrig = false,
      desc = "Quotes",
    },
    fmta(
      [[
        ``<>''
      ]],
      {
        i(1),
      }
    ),
    {
      condition = tex.in_text,
    }
  ),

  -- s(
  --   {
  --     trig = "(%d)q",
  --     regTrig = true,
  --     wordTrig = false,
  --     desc = "Quad and qquad commands for spacing in math environment"
  --   }
  -- )

  -- Color text
  s({
    trig = "ct",
    wordTrig = false,
    desc = "Color text",
  }, fmta([[\textcolor{<>}{<>}]], { i(2), d(1, get_visual) })),
  s(
    { trig = "te", wordTrig = false, desc = "Emphatize text with visual selection" },
    fmta([[\emph{<>}]], { d(1, get_visual) }),
    { condition = tex.in_text }
  ),
  s(
    { trig = "ti", wordTrig = false, desc = "Italic text with visual selection" },
    fmta([[\textit{<>}]], { d(1, get_visual) }),
    { condition = tex.in_text }
  ),
  s(
    { trig = "tb", wordTrig = false, desc = "Bold text with visual selection" },
    fmta([[\textbf{<>}]], { d(1, get_visual) }),
    { condition = tex.in_text }
  ),
  s(
    { trig = "tt", desc = "Normal text inside mathzone with visual selection" },
    fmta([[\text{<>}]], { d(1, get_visual) }),
    { condition = tex.in_mathzone }
  ),
}

ls.add_snippets("tex", misc)

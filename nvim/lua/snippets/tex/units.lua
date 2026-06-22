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

-- this will only expand \qty{}{<here>}
tex.in_unit_arg = function()
  return cmd("texSIArgUnit")
end

-- this will only expand \qty[<here>]{}{<here>}
tex.in_unit_opt = function()
  return cmd("texSIOptNU")
end

local siunitx = {
  s(
    {
      trig = "qty",
      wordTrig = false,
      desc = "Command for units",
    },
    fmta(
      [[
        \qty<>{<>}{<>}
      ]],
      {
        c(1, {
          fmta(
            [[
            	[<>]
            ]],
            {
              i(1),
            }
          ),
          sn(nil, { t("") }),
        }),
        i(2),
        i(3),
      }
    ),
    {
      condition = function()
        return tex.in_text or tex.in_mathzone
      end,
    }
  ),
  s(
    {
      trig = "(%a)eV",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      desc = "Automatic eV units with prefix.",
    },
    fmta([[\<>eV]], {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_unit_arg }
  ),
}

ls.add_snippets("tex", siunitx)

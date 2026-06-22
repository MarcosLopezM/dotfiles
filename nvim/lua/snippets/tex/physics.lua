local ls = require("luasnip")
local extras = require("luasnip.extras")
local events = require("luasnip.util.events")
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local postfix = require("luasnip.extras.postfix").postfix
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

-- Comment detection
tex.in_comment = function() -- comment detection
  return vim.fn["vimtex#syntax#in_comment"]() == 1
end

-- Inside specific environment
local function env(name)
  local is_inside = vim.fn["vimtex#env#is_inside"](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end

-- Expand command
local function cmd(name)
  return vim.fn["vimtex#syntax#in"](name) == 1
end

-- Helper function to get visual selection
local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

local physics_ctes = {
  s({ trig = "hb", wordTrig = false, desc = "hbar" }, {
    t("\\hbar"),
  }, { condition = tex.in_mathzone }),
}

local pauli_matrix = function(_, snip)
  local pauli_mat = snip.captures[1]
  local pauli = {
    x = {
      "\\begin{pNiceMatrix}",
      "0 & 1\\\\",
      "1 & 0",
      "\\end{pNiceMatrix}",
    },
    y = {
      "\\begin{pNiceMatrix}",
      "0 & -i\\\\",
      "i & 0",
      "\\end{pNiceMatrix}",
    },
    z = {
      "\\begin{pNiceMatrix}",
      "1 & 0\\\\",
      "0 & -1",
      "\\end{pNiceMatrix}",
    },
  }

  local data_mat = pauli[pauli_mat]

  return sn(nil, t(data_mat))
end

local qm_cmds = {
  -- Bra
  postfix({
    trig = ".bra",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Bra",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\bra{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condtion = tex.in_mathzone }),

  s(
    {
      trig = "bra",
      desc = "Bra",
    },
    fmta(
      [[
    \bra{<>}
  ]],
      {
        i(1),
      }
    ),
    {
      condition = tex.in_mathzone,
    }
  ),

  -- Ket
  s(
    {
      trig = "ket",
      desc = "Ket",
    },
    fmta(
      [[
        \ket{<>}
      ]],
      {
        i(1),
      }
    ),
    {
      condition = tex.in_mathzone,
    }
  ),

  postfix({
    trig = ".ket",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Ket",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\ket{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condtion = tex.in_mathzone }),

  s(
    {
      trig = "braket",
      wordTrig = false,
      desc = "Braket",
    },
    fmta(
      [[
    \braket{<>}{<>}
  ]],
      {
        i(1),
        i(2),
      }
    ),
    {
      condition = tex.in_mathzone,
    }
  ),

  -- Matrix element <wave|Op|wave>
  s(
    {
      trig = "mel",
      wordTrig = false,
      desc = "Matrix element",
    },
    fmta(
      [[
      \matrixel{<>}{<>}{<>}
      ]],
      {
        i(1),
        i(2),
        i(3),
      }
    ),
    {
      condition = tex.in_mathzone,
    }
  ),

  -- Commutator [A, B]
  s(
    {
      trig = "com",
      wordTrig = false,
      desc = "Commutator",
    },
    fmta(
      [[
            [<>, <>]
            ]],
      {
        i(1),
        i(2),
      }
    ),
    {
      condition = tex.in_mathzone,
    }
  ),

  -- Kronecker delta
  s(
    {
      trig = "dk",
      wordTrig = false,
      desc = "Kronecker delta",
    },
    fmta(
      [[
        \delta_{<>}
      ]],
      {
        i(1),
      }
    ),
    {
      conditon = tex.in_mathzone,
    }
  ),

  -- Levi=Civita symbol
  s(
    {
      trig = "lc",
      wordTrig = false,
      desc = "Levi-Civita symbol",
    },
    fmta(
      [[
              \epsilon_{<>}
            ]],
      {
        i(1),
      }
    ),
    {
      conditon = tex.in_mathzone,
    }
  ),

  -- Pauli matrices
  -- sigma_x
  s(
    {
      trig = "s([xyz])",
      regTrig = true,
      wordTrig = false,
      desc = "Pauli matrices",
    },
    fmta(
      [[
            <>
            ]],
      {
        d(1, pauli_matrix),
      }
    ),
    {
      conditon = tex.in_mathzone,
    }
  ),
}

ls.add_snippets("tex", physics_ctes)
ls.add_snippets("tex", qm_cmds)

local ls = require("luasnip")
local extras = require("luasnip.extras")
local events = require("luasnip.util.events")
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras").line_begin
local postfix = require("luasnip.extras.postfix").postfix
local r = ls.restore_node
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local m = extras.match
local d = ls.dynamic_node
local c = ls.choice_node
local c = ls.choice_node
local d = ls.dynamic_node
local conds = require("luasnip.extras.expand_conditions")
local match_greek = require("snippets.tex.greek").match_greek
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

-- tex.in_preamble = function()
--     return not env("document")
-- end

-- tex.in_text = function()
--     return env("document") and not tex.in_mathzone()
-- end

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

local generate_matrix = function(_, snip)
  local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t(" & "))
      table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t({ "\\\\", "" }))
  end
  -- fix last node.
  nodes[#nodes] = t("\\\\")
  return sn(nil, nodes)
end

local differentiation_cmds = {
  s(
    {
      trig = "([mpo])dv",
      regTrig = true,
      wordTrig = false,
      desc = "Material, partial, and ordinary derivatives",
    },
    fmta(
      [[
              \<>{<>}{<>}
            ]],
      {
        f(function(_, snip)
          return snip.captures[1] .. "dv"
        end),
        i(1, "f"),
        i(2, "x"),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  -- Multiple differentials
  s(
    {
      trig = "([mpso])df",
      regTrig = true,
      wordTrig = false,
      desc = "Material, partial, slash and ordinary differentials",
    },
    fmta(
      [[
              \<>{<>}
        ]],
      {
        f(function(_, snip)
          return snip.captures[1] .. "dif"
        end),
        i(1, "x"),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  -- Derivatives in tensor notation
  -- Partial derivative
  s(
    {
      trig = "p[.](%a)",
      regTrig = true,
      snippetType = "autosnippet",
      desc = "Partial derivative with respect to (auto) variable in tensor notation",
    },
    fmta([[\pdv{<>}!{<>}]], {
      i(1),
      d(2, match_greek),
    }),
    { condition = tex.in_mathzone }
  ),
  -- Contravariant notation
  s(
    {
      trig = "c[.](%a)",
      regTrig = true,
      snippetType = "autosnippet",
      desc = "Partial derivative in contravariant notation with respect to (auto) variable in tensor notation",
    },
    fmta([[\pdif*[order = <>]{<>}]], {
      d(1, match_greek),
      i(2),
    }),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "curl", wordTrig = false, desc = "Curl operator" },
    fmta(
      [[
              \nabla \mul{<>}
            ]],
      {
        i(1),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "div", wordTrig = false, desc = "Divergence operator" },
    fmta(
      [[
              \nabla \cdot{<>}
            ]],
      {
        i(1),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "grad", wordTrig = false, desc = "Gradient operator" },
    fmta(
      [[
                  \nabla{<>}
                ]],
      {
        i(1),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "lap", wordTrig = false, desc = "Laplacian operator" },
    fmta(
      [[
                  <>{<>}
                ]],
      {
        c(1, {
          t("\\nabla^{2}"),
          t("\\Delta"),
        }),
        i(2),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  postfix({
    trig = ".dt",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "First derivative of time",
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\dot{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".ddt",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Second derivative of time",
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\ddot{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".Dif",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Difference of quantity",
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\adif{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),
}

-- local dot_or_cross = function(_, snip)
--     local prod = snip.captures[1]
--
--     if prod == "d" then
--         return sn(nil, t("\\cdot"))
--     elseif prod == "c" then
--         return sn(nil, t("\\mul"))
--     end
-- end
local dot_or_cross = function(_, snip)
  local prod = snip.captures[1]

  local commands = {
    d = "\\dotprod",
    c = "\\cprod",
  }

  local commnd = commands[prod] or "\\dprod"
  return sn(
    nil,
    fmta(commnd .. "{<>}{<>}", {
      i(1),
      i(2),
    })
  )
end

local vectors = {
  -- Absolute value
  s(
    {
      trig = "abs",
      desc = "Absolute value",
    },
    fmta(
      [[
        \abs{<>}
      ]],
      {
        d(1, get_visual),
      }
    ),
    {
      condition = tex.in_mathzone,
    }
  ),

  postfix({
    trig = ".vec",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Vector",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\vect{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".hat",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Unitary vector or operator",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\op{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".hu",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Operator with superscript",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\op{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
    t("{"),
    t("}"),
    t("{"),
    i(1),
    t("}"),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".hs",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Operator with subscript",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\op{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
    t("{"),
    i(1),
    t("}"),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".dag",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Hermitian conjugate",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\hc{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".du",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Daggger operator with superscript",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\op{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
    t("{"),
    t("}"),
    t("{"),
    i(1),
    t("}"),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".ds",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Daggger operator with subscript",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\op{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
    t("{"),
    i(1),
    t("}"),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".bvec",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Bold vector",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\bm{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  postfix({
    trig = ".dbl",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Double overline for matrix",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\dbloverline{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  s(
    {
      trig = "conj",
      match_pattern = [[[\\%w%.%_%-%"%']+$]],
      wordTrig = false,
      desc = "Complex conjugate",
      snippetType = "autosnippet",
    },
    fmta(
      [[
        \overline{<>}
      ]],
      {
        i(1),
      }
    ),
    {
      condition = tex.in_mathzone,
    }
  ),

  -- Auto subscript
  s(
    {
      trig = "(\\?%w+)%*(%w)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      desc = "Auto subscript",
    },
    fmta("<>_{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  -- Auto superscript
  s(
    {
      trig = "(\\?%w+)&(%w)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      desc = "Auto superscript",
    },
    fmta("<>^{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  -- Dot/Cross product
  s({
    trig = "([dc])prod",
    regTrig = true,
    snippetType = "autosnippet",
    wordTrig = false,
    desc = "Dot/Cross product",
  }, d(1, dot_or_cross), { condition = tex.in_mathzone }),
}

local elements = function(_, snip)
  local nelems = tonumber(snip.captures[1])
  local elems = {}

  for j = 1, nelems do
    table.insert(elems, i(j))
    table.insert(elems, t("^{2}"))

    if j < nelems then
      table.insert(elems, t(" + "))
    end
  end

  return sn(nil, elems)
end

local generate_unit_vector = function(_, snip)
  local rows = tonumber(snip.captures[1])
  local cols = tonumber(snip.captures[2])

  local nodes = {}

  if rows > 1 and cols == 1 then
    for j = 1, rows do
      table.insert(nodes, t(j == cols and "1" or "0"))
      if j < rows then
        table.insert(nodes, t({ "\\\\", "" }))
      end
    end
  elseif rows == 1 and cols > 1 then
    for k = 1, cols do
      if k > 1 then
        table.insert(nodes, t(" & "))
      end
      table.insert(nodes, t(k == rows and "1" or "0"))
    end
  end

  return sn(nil, nodes)
end

local math_objects = {
  -- Unitary vectors
  s(
    {
      trig = "u(%d)x(%d)",
      regTrig = true,
      wordTrig = false,
      desc = "Unitary vector of dimension 1 by m or n by n",
    },
    fmta(
      [[
        \begin{pNiceMatrix}
          <>
        \end{pNiceMatrix}
      ]],
      {
        d(1, generate_unit_vector),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  -- Matrices nxn
  s(
    {
      trig = "([pbvV])mat(%d+)x(%d+)",
      regTrig = true,
      wordTrig = false,
      desc = "[pbvV] matrices of dimension m by n (m x n)",
    },
    fmta(
      [[
      	\begin{<>}
        	<>
        \end{<>}
      ]],
      {
        f(function(_, snip)
          return snip.captures[1] .. "NiceMatrix"
        end, { 1 }),
        d(1, generate_matrix),
        f(function(_, snip)
          return snip.captures[1] .. "NiceMatrix"
        end, { 1 }),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    {
      trig = "norm(%d)",
      regTrig = true,
      wordTrig = false,
      desc = "Norm in 2D or 3D",
      snippetType = "autosnippet",
    },
    fmta([[\norm{<>}]], {
      d(1, elements),
    }),
    {
      condition = tex.in_mathzone,
    }
  ),

  -- Average
  postfix({
    trig = ".avg",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Average",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\avg{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  -- Norm
  postfix({
    trig = ".norm",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Norm",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\norm{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  -- Sum
  s(
    {
      trig = "sum",
      desc = "Sum with optional subscript and superscript ",
    },
    fmta(
      [[
        \sum<><><>
      ]],
      {
        c(1, {
          fmta([[_{<>}]], { i(1) }),
          sn(nil, { t("") }),
        }),
        c(2, {
          fmta([[^{<>}]], { i(1) }),
          sn(nil, { t(" ") }),
        }),
        i(3),
      }
    ),
    { condition = tex.in_mathzone }
  ),
}

local integrals_cmds = {
  -- Integral snippets
  s(
    { trig = "dint", wordTrig = false, desc = "Integral with differential at the start" },
    fmta(
      [[
              \int<>\odif[sep-end=\medspace<>]{<>} <>
            ]],
      {
        c(1, {
          fmta(
            [[
            	_{<>}^{<>}
            ]],
            {
              i(1),
              i(2),
            }
          ),
          sn(nil, { t(" ") }),
        }),
        c(2, {
          fmta(
            [[
               , <>
            ]],
            {
              i(1),
            }
          ),
          sn(nil, { t("") }),
        }),
        i(3),
        i(4),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "intd", wordTrig = false, desc = "Integral with differential at the end" },
    fmta(
      [[
              \int<><>\odif<>{<>}
            ]],
      {
        c(1, {
          fmta(
            [[
            	_{<>}^{<>}
            ]],
            {
              i(1),
              i(2),
            }
          ),
          sn(nil, { t(" ") }),
        }),
        i(2), -- Función a integrar
        c(3, {
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
        i(4), -- Variable de integración
      }
    ),
    { condition = tex.in_mathzone }
  ),
}

local math_cmds = {
  s("mk", {
    t("\\("),
    i(1),
    t("\\)"),
  }, {
    callbacks = {
      -- index `-1` means the callback is on the snippet as a whole
      [-1] = {
        [events.leave] = function()
          vim.cmd([[
                      autocmd InsertCharPre <buffer> ++once lua _G.if_char_insert_space()
                    ]])
        end,
      },
    },
    condition = tex.in_text,
  }),

  -- -- Star
  -- s(
  --   {
  --     trig = "([%a%)%]%}])*",
  --     regTrig = true,
  --     wordTrig = false,
  --     snippetType = "autosnippet",
  --   },
  --   fmta("<>^{*}", {
  --     f(function(_, snip)
  --       return snip.captures[1]
  --     end),
  --   }),
  --   { condition = tex.in_mathzone }
  -- ),

  -- Prime
  s(
    {
      trig = "([%a%)%]%}])|",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
    },
    fmta("<>^{\\prime}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  -- Auto tfrac fraction command
  s(
    {
      trig = "(%d+)&&(%d)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      desc = "Auto tfrac fraction command for numbers",
    },
    fmta("\\tfrac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  -- Auto dfrac fraction command
  s(
    {
      trig = "(%d+)//(%d)",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      desc = "Auto dfrac fraction command for numbers",
    },
    fmta("\\dfrac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  -- Dots
  s(
    {
      trig = "%.%.%.",
      regTrig = true,
      snippetType = "autosnippet",
      desc = "Dots",
    },
    t("\\dots"),
    {
      condition = tex.in_mathzone,
    }
  ),

  -- Center Dots
  s(
    {
      trig = "c(%.%.%.)",
      regTrig = true,
      snippetType = "autosnippet",
      desc = "Center Dots",
    },
    t("\\cdots"),
    {
      condition = tex.in_mathzone,
    }
  ),
}

local set_notation = {
  s(
    {
      trig = "set",
      wordTrig = false,
      desc = "Set notation",
    },
    fmta([[<>]], {
      c(1, {
        fmta([[\{<>\}]], { i(1) }),
        fmta([[\set{<> \given <>}]], {
          i(1),
          i(2),
        }),
      }),
    }),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "in", desc = "Element in" },
    fmta([[<>\in <>]], {
      i(1),
      i(2),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "ein", desc = "Exists element in" },
    fmta([[\exists <>\in <>]], {
      i(1),
      i(2),
    }),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "fin", desc = "For all elements in" },
    fmta([[\forall <>\in <>]], {
      i(1),
      i(2),
    }),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "fa", desc = "For all elements" },
    fmta([[\forall <>]], {
      i(1),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "scomp", wordTrig = false, desc = "Set Complement" },
    fmta([[\setminus <>]], { i(1) }),
    { condition = tex.in_mathzone }
  ),
}

-- Function related snippets
local fns = {
  s(
    { trig = "fdef", wordTrig = false, desc = "Function definition" },
    fmta([[<> \colon <> \to <>]], {
      i(1, "f"),
      i(2),
      i(3),
    }),
    { condition = tex.in_mathzone }
  ),
}

local calculus = {
  s(
    {
      trig = "lim",
      wordTrig = false,
      desc = "Limit of a function",
    },
    fmta([[\lim_{<> \to <>} <>]], {
      i(1),
      i(2),
      i(3),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "to", wordTrig = false, desc = "To directive" },
    fmta([[<> \to <>]], {
      i(1),
      i(2),
    }),
    { condition = tex.in_mathzone }
  ),
}

local math_fonts = {
  -- Mathcal
  postfix({
    trig = ".cal",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Calligraphic font",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\mathcal{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),

  -- Blackboard Bold
  s(
    { trig = "(%u)%1", regTrig = true, snippetType = "autosnippet", desc = "Automatic blackboard board font" },
    fmta([[\mathbb{<>}]], {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
}

local relation_symbols = {
  a = "\\approx",
  c = "\\coloneqq",
  e = "\\equiv",
  i = "\\cong", -- Isomorphism
  g = "\\geq",
  gg = "\\ggg",
  l = "\\leq",
  ll = "\\lll",
  n = "\\neq",
  nc = "\\eqqcolon",
  s = "\\sim",
  se = "\\simeq",
  ss = "\\subset",
  sse = "\\subseteq",
}

local choose_relation_symbol = function(_, snip)
  return sn(nil, t(relation_symbols[snip.captures[1]] or ""))
end

local symbols = {
  s({
    trig = "(%a+)=",
    regTrig = true,
    desc = "Choose relation symbol",
    snippetType = "autosnippet",
    wordTrig = false,
  }, {
    d(1, choose_relation_symbol),
  }, { condition = tex.in_mathzone }),

  s(
    { trig = "s/", snippetType = "autosnippet", desc = "Feynman Slash Notation" },
    fmta("\\fms{<>}", i(1)),
    { condition = tex.in_mathzone }
  ),

  s(
    {
      trig = "pp(%d?)",
      wordTrig = false,
      regTrig = true,
      desc = "2pi term with or without power",
    },
    fmta([[<>]], {
      d(1, function(_, snip)
        local power = snip.captures[1]
        if power == "" then
          return sn(nil, t("2\\pi"))
        else
          return sn(nil, t("(2\\pi)^{" .. power .. "}"))
        end
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  postfix({
    trig = ".til",
    match_pattern = [[[\\%w%.%_%-%"%']+$]],
    desc = "Tilde accent",
    wordTrig = false,
    snippetType = "autosnippet",
  }, {
    f(function(_, parent)
      return "\\tilde{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }, { condition = tex.in_mathzone }),
}

local envs_cmds = {
  s(
    {
      trig = "cases",
      wordTrig = false,
      desc = "dcases environment from mathtools package",
    },
    fmta(
      [[
      \begin{dcases}
        <>
      \end{dcases}
      ]],
      {
        i(1),
      }
    ),
    { condition = tex.in_mathzone }
  ),
}

ls.add_snippets("tex", calculus)
ls.add_snippets("tex", differentiation_cmds)
ls.add_snippets("tex", envs_cmds)
ls.add_snippets("tex", math_objects)
ls.add_snippets("tex", math_cmds)
ls.add_snippets("tex", integrals_cmds)
ls.add_snippets("tex", vectors)
ls.add_snippets("tex", math_fonts)
ls.add_snippets("tex", symbols)
ls.add_snippets("tex", set_notation)
ls.add_snippets("tex", fns)

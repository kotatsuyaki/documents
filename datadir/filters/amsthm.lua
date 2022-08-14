--[[
-- amsthm.lua - Pandoc Lua filter to handle Div's with ".thm" and ".proof" classes.
--
-- Example usage:
--
--     ::: {.thm}
--     This theorem is awesome.
--     :::
--
--     ::: {.proof}
--     Since it is my theorem, it is awesome.
--     :::
--
-- For Docx, Html5, and CommonMark outputs, this Lua filter takes care of everything.
-- For LaTeX outputs, add this to the Yaml header:
--
--     header-includes:
--       - |
--         \usepackage{amsthm}
--         \newtheorem{thm}{Theorem}
--         \newtheorem{lem}{Lemma}
--]]

local null = pandoc.Null()
local surround_elements = {
  latex = {
    thm = {
      pandoc.RawInline('latex', [[\begin{thm}]]),
      pandoc.RawInline('latex', [[\end{thm}]]),
    },
    proof = {
      pandoc.RawInline('latex', [[\begin{proof}]]),
      pandoc.RawInline('latex', [[\end{proof}]]),
    },
  },
  -- Nothing has to be done around the elements
  html5 = {
    thm = {
      null,
      null,
    },
    proof = {
      null,
      null,
    },
  },
  commonmark = {
    thm = {
      pandoc.Strong('Theorem.'),
      null,
    },
    proof = {
      pandoc.Emph('Proof.'),
      pandoc.HorizontalRule(),
    },
  },
  docx = {
    thm = {
      pandoc.Strong('Theorem.'),
      null,
    },
    proof = {
      pandoc.Emph('Proof.'),
      pandoc.HorizontalRule(),
    },
  },
}

function surround_div_with_env(div, env)
  if not surround_elements[FORMAT] then
    print('The amsthm Lua filter does not support this output format:', FORMAT)
    return div
  end

  local pre, post = table.unpack(surround_elements[FORMAT][env])
  div.content:insert(1, pre)
  div.content:insert(post)
  return div
end

function Div(div)
  supported_environments = { 'thm', 'proof' }
  for i, env in ipairs(supported_environments) do
    if div.attr.classes:includes(env) then
      return surround_div_with_env(div, env)
    end
  end
end

function Pandoc(doc)
  -- Insert style tag at the end of body
  if FORMAT == 'html5' then
    doc.blocks:insert(
      pandoc.RawInline(
        'html5',
        [[<style>
          .thm:before {
            content: "Theorem.";
            font-weight: bold;
          }

          .proof:before {
            content: "Proof.";
            font-style: italic;
          }

          /* Put :before and body on the same line */
          .thm > *, .proof > * {
            display: inline;
          }
        </style>]]
      )
    )
  end
  return doc
end

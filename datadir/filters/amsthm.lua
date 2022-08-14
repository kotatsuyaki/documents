--[[
-- amsthm.lua - Pandoc Lua filter to handle Div's with ".thm", ".lem", and ".proof" classes.
--
-- Example usage:
--
--     ::: {.thm title="The Awesome Pandoc Theorem"}
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

-- Extract and format the {title="..."} attribute of the div
function surround_elements_commonmark_docx(div)
  local title = div.attr.attributes['title'] or ''

  local thm_heading = ''
  local lem_heading = ''

  if title ~= '' then
    thm_text = string.format('Theorem (%s).', title)
    lem_text = string.format('Lemma (%s).', title)
    thm_heading = pandoc.utils.blocks_to_inlines(pandoc.read(thm_text, 'markdown').blocks)
    lem_heading = pandoc.utils.blocks_to_inlines(pandoc.read(lem_text, 'markdown').blocks)
  else
    thm_heading = 'Theorem.'
    lem_heading = 'Lemma.'
  end
  return {
    thm = {
      pandoc.Strong(thm_heading),
      null,
    },
    lem = {
      pandoc.Strong(lem_heading),
      null,
    },
    proof = {
      pandoc.Emph('Proof.'),
      pandoc.HorizontalRule(),
    },
  }
end

local surround_elements = {
  latex = function(div)
    local title = div.attr.attributes['title'] or ''
    -- markdown string => Pandoc doc => latex string
    title = pandoc.write(pandoc.read(title, 'markdown'), 'latex')
    return {
      thm = {
        pandoc.RawInline('latex', string.format([=[\begin{thm}[%s]]=], title)),
        pandoc.RawInline('latex', [[\end{thm}]]),
      },
      lem = {
        pandoc.RawInline('latex', string.format([=[\begin{lem}[%s]]=], title)),
        pandoc.RawInline('latex', [[\end{lem}]]),
      },
      proof = {
        pandoc.RawInline('latex', [[\begin{proof}]]),
        pandoc.RawInline('latex', [[\end{proof}]]),
      },
    }
  end,
  html5 = function(div)
    local title = div.attr.attributes['title'] or ''
    -- markdown string => Pandoc doc => inlines
    if title ~= '' then
      title = string.format('(%s) ', title)
      title = pandoc.utils.blocks_to_inlines(pandoc.read(title, 'markdown').blocks)
    end
    return {
      thm = { pandoc.Emph(title), null },
      lem = { pandoc.Emph(title), null },
      proof = { null, null }
    }
  end,
  commonmark = surround_elements_commonmark_docx,
  docx = surround_elements_commonmark_docx,
}

function surround_div_with_env(div, env)
  if not surround_elements[FORMAT] then
    print('The amsthm Lua filter does not support this output format:', FORMAT)
    return div
  end

  local pre, post = table.unpack(surround_elements[FORMAT](div)[env])
  div.content:insert(1, pre)
  div.content:insert(post)
  return div
end

function Div(div)
  supported_environments = { 'thm', 'lem', 'proof' }
  for i, env in ipairs(supported_environments) do
    if div.attr.classes:includes(env) then
      print(div.attr.attributes['title'])
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

          .lem:before {
            content: "Lemma.";
            font-weight: bold;
          }

          .proof:before {
            content: "Proof.";
            font-style: italic;
          }

          /* Put :before and body on the same line */
          .thm > *, .proof > *, .lem > * {
            display: inline;
          }
        </style>]]
      )
    )
  end
  return doc
end

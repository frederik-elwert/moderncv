--- moderncv.lua – converts markdown CVs to LaTeX using the moderncv package
---
--- Copyright: © 2024 Contributors
--- License: MIT – see LICENSE for details

-- Makes sure users know if their pandoc version is too old for this
-- filter.
PANDOC_VERSION:must_be_at_least '2.17'

--- Converts a markdown CV to moderncv LaTeX format
local function convert_to_moderncv(doc)
  -- Get metadata
  local meta = doc.meta

  -- Build moderncv preamble
  local header_includes = {}

  -- Add moderncv theme and color setup
  table.insert(header_includes, pandoc.RawBlock('latex', '\\moderncvstyle{classic}'))
  table.insert(header_includes, pandoc.RawBlock('latex', '\\moderncvcolor{blue}'))

  -- Add personal information from metadata
  if meta.name then
    local name_str = pandoc.utils.stringify(meta.name)
    table.insert(header_includes, pandoc.RawBlock('latex', '\\name{' .. name_str .. '}{}'))
  end

  if meta.title then
    local title_str = pandoc.utils.stringify(meta.title)
    table.insert(header_includes, pandoc.RawBlock('latex', '\\title{' .. title_str .. '}'))
  end

  if meta.address then
    local address_str = pandoc.utils.stringify(meta.address)
    table.insert(header_includes, pandoc.RawBlock('latex', '\\address{' .. address_str .. '}'))
  end

  if meta.phone then
    local phone_str = pandoc.utils.stringify(meta.phone)
    table.insert(header_includes, pandoc.RawBlock('latex', '\\phone{' .. phone_str .. '}'))
  end

  if meta.email then
    local email_str = pandoc.utils.stringify(meta.email)
    table.insert(header_includes, pandoc.RawBlock('latex', '\\email{' .. email_str .. '}'))
  end

  if meta.homepage then
    local homepage_str = pandoc.utils.stringify(meta.homepage)
    table.insert(header_includes, pandoc.RawBlock('latex', '\\homepage{' .. homepage_str .. '}'))
  end

  if meta.photo then
    local photo_str = pandoc.utils.stringify(meta.photo)
    table.insert(header_includes, pandoc.RawBlock('latex', '\\photo{' .. photo_str .. '}'))
  end

  if meta.extrainfo then
    local extrainfo_str = pandoc.utils.stringify(meta.extrainfo)
    table.insert(header_includes, pandoc.RawBlock('latex', '\\extrainfo{' .. extrainfo_str .. '}'))
  end

  -- Add header-includes to metadata
  if meta['header-includes'] then
    -- If header-includes already exists, append to it
    local existing = meta['header-includes']
    if existing.t == 'MetaList' then
      for _, block in ipairs(header_includes) do
        table.insert(existing, pandoc.MetaBlocks{block})
      end
    else
      -- Convert single item to list and append
      local new_list = {existing}
      for _, block in ipairs(header_includes) do
        table.insert(new_list, pandoc.MetaBlocks{block})
      end
      meta['header-includes'] = pandoc.MetaList(new_list)
    end
  else
    -- Create new header-includes
    local meta_blocks = {}
    for _, block in ipairs(header_includes) do
      table.insert(meta_blocks, pandoc.MetaBlocks{block})
    end
    meta['header-includes'] = pandoc.MetaList(meta_blocks)
  end

  -- Set document class to moderncv
  meta.documentclass = pandoc.MetaString('moderncv')

  return doc
end

--- Converts definition lists to moderncv entries
local function convert_definition_lists(elem)
  if elem.t == 'DefinitionList' then
    local new_blocks = {}

    for _, item in ipairs(elem.content) do
      local term = item[1]  -- The term (e.g., date range)
      local definitions = item[2]  -- List of definitions

      -- Convert term to string
      local term_str = pandoc.utils.stringify(term)

      -- Process each definition
      for _, def in ipairs(definitions) do
        -- Convert definition blocks to string
        local def_str = ""
        for _, block in ipairs(def) do
          if block.t == 'Para' then
            def_str = def_str .. pandoc.utils.stringify(block.content)
          else
            def_str = def_str .. pandoc.utils.stringify(block)
          end
        end

        -- Create cvitem command
        local cvitem = '\\cvitem{' .. term_str .. '}{' .. def_str .. '}'
        table.insert(new_blocks, pandoc.RawBlock('latex', cvitem))
      end
    end

    return new_blocks
  end
end

return {
  { Pandoc = convert_to_moderncv },
  { DefinitionList = convert_definition_lists }
}

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

  -- Helper function to add meta fields to header_includes
  local function add_meta_field(field_name, latex_command)
    latex_command = latex_command or field_name  -- Use field_name as default
    if meta[field_name] then
      local field_str = pandoc.utils.stringify(meta[field_name])
      if field_str and field_str ~= "" then
        table.insert(header_includes, pandoc.RawBlock('latex', '\\' .. latex_command .. '{' .. field_str .. '}'))
      end
    end
  end

  -- Add personal information from metadata
  -- Special case for name which has empty second parameter
  if meta.name then
    local name_str = pandoc.utils.stringify(meta.name)
    if name_str and name_str ~= "" then
      table.insert(header_includes, pandoc.RawBlock('latex', '\\name{' .. name_str .. '}{}'))
    end
  end

  -- Add other meta fields (field name matches LaTeX command)
  add_meta_field('title')
  add_meta_field('address')
  add_meta_field('phone')
  add_meta_field('email')
  add_meta_field('homepage')
  add_meta_field('photo')
  add_meta_field('extrainfo')

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

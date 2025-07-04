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

  -- Add default settings
  table.insert(header_includes, pandoc.RawBlock('latex', [[
\usepackage[scale=0.75]{geometry}
\AtBeginDocument{\recomputelengths}
]]))

  -- Add moderncv theme and color setup with configurable options
  local cv_style = meta.cvstyle and pandoc.utils.stringify(meta.cvstyle) or "classic"
  local cv_color = meta.cvcolor and pandoc.utils.stringify(meta.cvcolor) or "blue"

  table.insert(header_includes, pandoc.RawBlock('latex', '\\moderncvstyle{' .. cv_style .. '}'))
  table.insert(header_includes, pandoc.RawBlock('latex', '\\moderncvcolor{' .. cv_color .. '}'))

  -- Helper function to convert meta content to inlines
  local function meta_to_inlines(field_content)
    if field_content.t == 'MetaInlines' then
      return field_content
    elseif field_content.t == 'MetaString' then
      return pandoc.Inlines{pandoc.Str(field_content)}
    elseif type(field_content) == 'table' and #field_content > 0 and field_content[1].t then
      -- This is likely a list of inlines (MetaInlines without .t field)
      return field_content
    else
      -- For other types, try to stringify but this loses formatting
      local str = pandoc.utils.stringify(field_content)
      if str and str ~= "" then
        return pandoc.Inlines{pandoc.Str(str)}
      end
    end
    return nil
  end

  -- Helper function to detect if content is a YAML list (MetaList)
  local function is_yaml_list(field_content)
    return not field_content.t and type(field_content) == 'table' and #field_content > 1 and
           type(field_content[1]) == 'table' and not field_content[1].t
  end

  -- Helper function to detect if content is a YAML mapping
  local function is_yaml_mapping(field_content)
    return not field_content.t and type(field_content) == 'table' and not field_content[1]
  end

  -- Helper function to create LaTeX command with content
  local function create_latex_command(latex_command, inlines, extra_suffix)
    extra_suffix = extra_suffix or ""
    local content = {
      pandoc.RawInline('latex', '\\' .. latex_command .. '{')
    }
    for _, inline in ipairs(inlines) do
      table.insert(content, inline)
    end
    table.insert(content, pandoc.RawInline('latex', '}' .. extra_suffix))
    return pandoc.Para(content)
  end

  -- Helper function to add meta fields to header_includes
  -- This preserves markdown formatting by creating inline sequences
  -- Supports both single values and lists for multi-parameter commands
  local function add_meta_field(field_name, latex_command, extra_suffix)
    latex_command = latex_command or field_name
    extra_suffix = extra_suffix or ""

    local field_content = meta[field_name]
    if not field_content then return end

    if is_yaml_list(field_content) then
      -- Handle list of parameters (e.g., address: [street, city, country])
      local content = { pandoc.RawInline('latex', '\\' .. latex_command) }
      
      for _, item in ipairs(field_content) do
        table.insert(content, pandoc.RawInline('latex', '{'))
        local item_inlines = meta_to_inlines(item)
        if item_inlines then
          for _, inline in ipairs(item_inlines) do
            table.insert(content, inline)
          end
        end
        table.insert(content, pandoc.RawInline('latex', '}'))
      end
      
      table.insert(content, pandoc.RawInline('latex', extra_suffix))
      table.insert(header_includes, pandoc.Para(content))
    else
      -- Handle single value
      local inlines = meta_to_inlines(field_content)
      if inlines and #inlines > 0 then
        table.insert(header_includes, create_latex_command(latex_command, inlines, extra_suffix))
      end
    end
  end

  -- Helper function to handle fields with optional parameters (phone and social)
  local function add_optional_param_field(field_name, latex_command)
    latex_command = latex_command or field_name

    local field_content = meta[field_name]
    if not field_content then return end

    if is_yaml_mapping(field_content) then
      -- Handle as YAML mapping (e.g., phone: {mobile: "123", fixed: "456"})
      for param_type, value in pairs(field_content) do
        if value then
          local value_str = pandoc.utils.stringify(value)
          if value_str and value_str ~= "" then
            local content = {
              pandoc.RawInline('latex', '\\' .. latex_command .. '[' .. param_type .. ']{' .. value_str .. '}')
            }
            table.insert(header_includes, pandoc.Para(content))
          end
        end
      end
    else
      -- Handle as single value (fallback for backwards compatibility)
      local inlines = meta_to_inlines(field_content)
      if inlines and #inlines > 0 then
        table.insert(header_includes, create_latex_command(latex_command, inlines))
      end
    end
  end

  -- Add personal information from metadata
  add_meta_field('name', 'name', '{}')  -- Special case: name command needs empty second parameter
  add_meta_field('title')
  add_meta_field('born')
  add_meta_field('address')
  add_optional_param_field('phone')  -- Supports both single value and mapping
  add_meta_field('email')
  add_meta_field('homepage')
  add_optional_param_field('social')  -- Supports YAML mapping
  add_meta_field('photo')
  add_meta_field('quote')
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

      -- Process each definition
      for _, def in ipairs(definitions) do
        -- Create paragraph with cvitem structure that preserves formatting
        local content = {
          pandoc.RawInline('latex', '\\cvitem{' .. pandoc.utils.stringify(term) .. '}{')
        }

        -- Add the formatted definition content
        for _, block in ipairs(def) do
          if block.t == 'Para' or block.t == 'Plain' then
            -- Add the paragraph/plain content as inlines
            for _, inline in ipairs(block.content) do
              table.insert(content, inline)
            end
          else
            -- For other block types, convert to inlines if possible
            -- This is a simplified approach - could be enhanced for other block types
            local str = pandoc.utils.stringify(block)
            if str and str ~= "" then
              table.insert(content, pandoc.Str(str))
            end
          end
        end

        table.insert(content, pandoc.RawInline('latex', '}'))
        table.insert(new_blocks, pandoc.Para(content))
      end
    end

    return new_blocks
  end
end

return {
  { Pandoc = convert_to_moderncv },
  { DefinitionList = convert_definition_lists }
}

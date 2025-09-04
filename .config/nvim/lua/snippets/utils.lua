-- This file contains utility functions for python snippets

local ls = require("luasnip")
local snip = ls.snippet
local insert = ls.insert_node
local text = ls.text_node

----------------------------------------------------------
local function split_lines(str)
  local lines = {}
  for line in str:gmatch("([^\n]*)\n?") do
    if line ~= nil then
      line = line:gsub("\\{", "{"):gsub("\\}", "}")
      table.insert(lines, line)
    end
  end
  -- Remove empty string at the end if present
  if lines[#lines] == "" then
    table.remove(lines)
  end

  return lines
end
----------------------------------------------------------
-- A wrapper that parses {1}, {2}, etc. into insert nodes
local function snippetf(trig, template)
  local nodes  = {}
  local cursor = 1

  while true do
    local start_pos, end_pos = string.find(template, "{%d+}", cursor)
    if not start_pos then
      -- No more matches, add remaining text
      table.insert(nodes, text(split_lines(template:sub(cursor))))
      break
    end

    -- Add text before the match
    if start_pos > cursor then
      table.insert(nodes, text(split_lines(template:sub(cursor, start_pos - 1))))
    end

    -- Extract the number inside the {}
    local index = tonumber(template:sub(start_pos + 1, end_pos - 1))
    table.insert(nodes, insert(index))

    cursor = end_pos + 1
  end

  return snip(trig, nodes)
end

return {
  snippetf = snippetf
}
----------------------------------------------------------

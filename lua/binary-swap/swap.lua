local query = require('vim.treesitter.query')
local ts = require('vim.treesitter')
-- `ts.get_node_text` for NVIM v0.9.0-dev-1275+gcbbf8bd66-dirty and newer
-- see: https://github.com/neovim/neovim/pull/22761
local get_node_text = ts.get_node_text or query.get_node_text
local ts_ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

if not ts_ok then
  return
end

local M = {}

local OPPOSITES = {
  ['>='] = '<=',
  ['<='] = '>=',
  ['>'] = '<',
  ['<'] = '>',
  ['<<'] = '>>',
  ['>>'] = '<<',
}

local BINARY = {
  'binary_expression',
  'binary_operator',
  'boolean_operator',
  'comparison_operator',
}
local OPERATOR_INDEX = 2

---Return TSNode with type 'binary_expression' or nil
---@param node TSNode
---@return TSNode|nil
local function get_binary_node(node)
  if vim.tbl_contains(BINARY, node:type()) then
    return node
  end

  local parent = node:parent()

  if not parent then
    return
  end

  return get_binary_node(parent)
end

---Returned list-like table with children of node
---@param node TSNode TSNode instance
---@return TSNode[]
local function collect_children(node)
  local children = {}

  for child in node:iter_children() do
    table.insert(children, child)
  end

  return children
end

---Returned swapped operands and opposite operator if it needs
---@param operands TSNode[]
---@param swap_operator? boolean Swap operator to opposite or not
---@return table[]
local function swap_operands(operands, swap_operator)
  local replacement = {}

  for idx = #operands, 1, -1 do
    local text = get_node_text(operands[idx], 0)

    local reversed_idx = #operands - idx + 1

    if swap_operator and idx == reversed_idx then
      local operator = OPPOSITES[text]

      if operator then
        text = operator
      end
    end

    local range = { operands[reversed_idx]:range() }
    table.insert(replacement, { text = vim.split(text, '\n'), range = range })
  end

  return replacement
end

---Format and replace binary expression under cursor
---@param swap_operator? boolean Swap operator to opposite or not
function M.format_and_replace(swap_operator)
  local parser = vim.treesitter.get_parser()
  parser:parse()

  local node = ts_utils.get_node_at_cursor(0)

  if not node then
    return
  end

  local binary_expression = get_binary_node(node)

  if not binary_expression then
    return
  end

  local operands = collect_children(binary_expression)

  local replacement = swap_operands(operands, swap_operator)

  for i = #replacement, 1, -1 do
    local sr, sc, er, ec = unpack(replacement[i].range)
    vim.api.nvim_buf_set_text(0, sr, sc, er, ec, replacement[i].text)
  end
end

return M

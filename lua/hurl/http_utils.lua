local M = {}

--- Find the HTTP verb in the given line
---@param line string
---@param current_line_number number
local function find_http_verb(line, current_line_number)
  if not line then
    return nil
  end

  local verbs = { 'GET', 'POST', 'PUT', 'DELETE', 'PATCH' }
  local verb_start, verb_end, verb

  for _, v in ipairs(verbs) do
    verb_start, verb_end = line:find(v)
    if verb_start then
      verb = v
      break
    end
  end

  if verb_start then
    return {
      line_number = current_line_number,
      start_pos = verb_start,
      end_pos = verb_end,
      method = verb,
    }
  else
    return nil
  end
end

--- Find the closest HURL entry at the current cursor position.
local function find_hurl_entry_positions_in_buffer()
  local ts = vim.treesitter
  local node = ts.get_node()

  while node and node:type() ~= 'entry' do
    node = node:parent()
  end

  if not node then
    return {
      current = 0,
      start_line = nil,
      end_line = nil,
    }
  else
    local r1, _, _ = node:start()
    local r2, _, _ = node:end_()
    return {
      current = r1 + 1,
      start_line = r1 + 1,
      end_line = r2 + 1,
    }
  end
end

M.find_hurl_entry_positions_in_buffer = find_hurl_entry_positions_in_buffer

return M

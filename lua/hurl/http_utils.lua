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

--- Find the HTTP verbs in the current buffer
---@return table
M.find_http_verb_positions_in_buffer = function()
  local buf = vim.api.nvim_get_current_buf()
  local total_lines = vim.api.nvim_buf_line_count(buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line_number = cursor[1]

  local next_entry = 0
  local current_index = 0
  local current_verb = nil
  local end_line = total_lines -- Default to the last line of the buffer

  for i = 1, total_lines do
    local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    local result = find_http_verb(line, i)
    if result then
      next_entry = next_entry + 1
      if i == current_line_number then
        current_index = next_entry
        current_verb = result
      elseif current_verb and i > current_verb.line_number then
        end_line = i - 1 -- The end line of the current verb is the line before the next verb starts
        break -- No need to continue once the end line of the current verb is found
      end
    end
  end

  if current_verb and current_index == next_entry then
    -- If the current verb is the last one, the end line is the last line of the buffer
    end_line = total_lines
  end

  return {
    current = current_index,
    start_line = current_verb and current_verb.line_number or nil,
    end_line = end_line,
  }
end

--- Find the closest HURL entry at the current cursor position.
M.find_hurl_entry_positions_in_buffer = function()
  local ts = vim.treesitter

  -- Look for closest `entry` node to cursor position.
  local current_node = ts.get_node()
  while current_node and current_node:type() ~= 'entry' do
    current_node = current_node:parent()
  end

  if not current_node then
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    return {
      current = 0,
      start_line = cursor_line,
      end_line = cursor_line,
    }
  else
    local r1, _, _ = current_node:start()
    local r2, _, _ = current_node:end_()

    local hurl_file = current_node:parent()

    local current_node_idx = 1
    if hurl_file and hurl_file:type() == 'hurl_file' then
      -- Find the current node index
      for node in hurl_file:iter_children() do
        if node:id() == current_node:id() then
          break
        end
        current_node_idx = current_node_idx + 1
      end
    else
      -- Parent node is not a hurl_file, HURL file must have errors.
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
      return {
        current = 0,
        start_line = cursor_line,
        end_line = cursor_line,
      }
    end

    return {
      current = current_node_idx,
      start_line = r1 + 1,
      end_line = r2,
    }
  end
end

return M

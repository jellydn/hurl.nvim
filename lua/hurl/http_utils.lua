local M = {}

--- Find the closest HURL entry at the current cursor position.
local function find_hurl_entry_positions_in_buffer()
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
      end_line = r2 + 1,
    }
  end
end

M.find_hurl_entry_positions_in_buffer = find_hurl_entry_positions_in_buffer

return M

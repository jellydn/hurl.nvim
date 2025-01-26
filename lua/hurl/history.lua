local utils = require('hurl.utils')
local M = {}

-- Store the last 10 responses
local response_history = {}
local max_history_size = 10

-- Add a response to the history
local function add_to_history(response)
  table.insert(response_history, 1, response)
  if #response_history > max_history_size then
    table.remove(response_history)
  end
end

-- Show the last response
function M.show_last_response()
  if #response_history == 0 then
    utils.notify('No response history available', vim.log.levels.INFO)
    return
  end

  local last_response = response_history[1]
  local ok, display = pcall(require, 'hurl.' .. (_HURL_GLOBAL_CONFIG.mode or 'split'))
  if not ok then
    utils.notify('Failed to load display module: ' .. display, vim.log.levels.ERROR)
    return
  end

  display.show(last_response, last_response.display_type or 'text')
end

-- Function to be called after each request
--- Update the history with the response
---@param response table
---@param type? string
function M.update_history(response, type)
  -- Ensure response_time is a number
  response.response_time = tonumber(response.response_time) or '-'

  if type == 'error' then
    response.display_type = 'shell'
  else
    -- Determine the content type and set display_type
    local content_type = response.headers['Content-Type']
      or response.headers['content-type']
      or 'text/plain'

    if content_type:find('json') then
      response.display_type = 'json'
    elseif content_type:find('html') then
      response.display_type = 'html'
    elseif content_type:find('xml') then
      response.display_type = 'xml'
    else
      response.display_type = 'text'
    end
  end

  add_to_history(response)
end

function M.get_last_response()
  return response_history[1]
end

return M

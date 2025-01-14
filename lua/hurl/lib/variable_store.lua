

local M = {}
local utils = require('hurl.utils')

-- Get the path for storing persisted variables
local function get_store_path()
  return vim.fn.stdpath('data') .. '/hurl_variables.json'
end

-- Load persisted variables from disk
function M.load_persisted_vars()
  local file_path = get_store_path()
  local file = io.open(file_path, 'r')
  if not file then
    return {}
  end
  
  local content = file:read('*all')
  file:close()
  
  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    utils.log_error('Failed to parse persisted variables: ' .. data)
    return {}
  end
  
  return data
end

-- Save variables to disk
function M.save_persisted_vars(vars)
  local file_path = get_store_path()
  local file = io.open(file_path, 'w')
  if not file then
    utils.log_error('Failed to open variable store for writing: ' .. file_path)
    return false
  end
  
  local ok, encoded = pcall(vim.json.encode, vars)
  if not ok then
    utils.log_error('Failed to encode variables: ' .. encoded)
    file:close()
    return false
  end
  
  file:write(encoded)
  file:close()
  return true
end

-- Parse variables from env file
function M.parse_env_file(file_path)
  local file = io.open(file_path, 'r')
  if not file then
    return {}
  end
  
  local vars = {}
  for line in file:lines() do
    local name, value = line:match('^([^=]+)=(.+)$')
    if name and value then
      vars[name:trim()] = value:trim()
    end
  end
  file:close()
  
  return vars
end

return M
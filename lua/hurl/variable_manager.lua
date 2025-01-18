

local M = {}
local utils = require('hurl.utils')
local Path = require('plenary.path')

-- Get the path for storing persistent variables
local function get_storage_path()
  local data_path = vim.fn.stdpath('data')
  return Path:new(data_path, 'hurl-nvim', 'variables.json')
end

-- Load variables from persistent storage
function M.load_persistent_vars()
  local storage_path = get_storage_path()
  if not storage_path:exists() then
    return {}
  end

  local content = storage_path:read()
  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    utils.log_error('Failed to parse persistent variables: ' .. data)
    return {}
  end
  return data
end

-- Save variables to persistent storage
function M.save_persistent_vars(vars)
  local storage_path = get_storage_path()
  -- Create directory if it doesn't exist
  storage_path:parent():mkdir({ parents = true, exists_ok = true })
  
  local ok, encoded = pcall(vim.json.encode, vars)
  if not ok then
    utils.log_error('Failed to encode variables: ' .. encoded)
    return false
  end
  
  storage_path:write(encoded, 'w')
  return true
end

-- Parse env file and extract variables
function M.parse_env_file(file_path)
  local vars = {}
  local file = io.open(file_path, 'r')
  if not file then return vars end

  for line in file:lines() do
    -- Skip comments and empty lines
    if not line:match('^%s*#') and line:match('%S') then
      local name, value = line:match('([^=]+)=(.+)')
      if name and value then
        vars[name:trim()] = value:trim()
      end
    end
  end
  
  file:close()
  return vars
end

-- Load variables from all configured env files
function M.load_env_vars()
  local vars = {}
  local env_files = _HURL_GLOBAL_CONFIG.find_env_files_in_folders()
  
  for _, env in ipairs(env_files) do
    if vim.fn.filereadable(env.path) == 1 then
      local env_vars = M.parse_env_file(env.path)
      vars = vim.tbl_extend('force', vars, env_vars)
    end
  end
  
  return vars
end

return M
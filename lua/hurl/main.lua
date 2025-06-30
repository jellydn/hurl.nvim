local utils = require('hurl.utils')
local http = require('hurl.http_utils')
local hurl_runner = require('hurl.lib.hurl_runner')
local codelens = require('hurl.codelens')

local M = {}

--- Run current file
--- It will throw an error if that is not valid hurl file
---@param opts table The options
local function run_current_file(opts)
  opts = opts or {}
  table.insert(opts, vim.fn.expand('%:p'))
  hurl_runner.execute_hurl_cmd(opts)
end

-- Run selection
---@param opts table The options
local function run_selection(opts)
  opts = opts or {}
  local lines = utils.get_visual_selection()
  if not lines then
    return
  end

  -- Create a temporary file with the lines to run
  local fname = utils.create_tmp_file(lines)
  if not fname then
    utils.log_warn('hurl: create tmp file failed')
    utils.notify('hurl: create tmp file failed. Please try again!', vim.log.levels.WARN)
    return
  end

  -- Add the temporary file to the arguments
  table.insert(opts, fname)
  hurl_runner.execute_hurl_cmd(opts)

  -- Clean up the temporary file after a delay
  local timeout = 1000
  vim.defer_fn(function()
    local success = os.remove(fname)
    if not success then
      utils.log_info('hurl: remove file failed ' .. fname)
      utils.notify('hurl: remove file failed', vim.log.levels.WARN)
    else
      utils.log_info('hurl: remove file success ' .. fname)
    end
  end, timeout)
end

-- Store the last used from_entry and to_entry
local last_from_entry
local last_to_entry

-- Run at current line
---@param start_line number
---@param end_line number|nil
---@param opts table
---@param callback? function
local function run_at_lines(start_line, end_line, opts, callback)
  opts = opts or {}
  local file_path = vim.fn.expand('%:p')

  -- Insert the file path first
  table.insert(opts, file_path)

  -- Then add the --from-entry and --to-entry options
  table.insert(opts, '--from-entry')
  table.insert(opts, tostring(start_line))
  if end_line then
    table.insert(opts, '--to-entry')
    table.insert(opts, tostring(end_line))
  end

  -- Store the last used from_entry and to_entry
  last_from_entry = start_line
  last_to_entry = end_line

  hurl_runner.execute_hurl_cmd(opts, callback)
end

-- Helper function to run verbose commands in split mode
local function run_verbose_command(filePath, fromEntry, toEntry, isVeryVerbose, additionalArgs)
  hurl_runner.run_hurl_verbose(filePath, fromEntry, toEntry, isVeryVerbose, additionalArgs)
end

---register the dotenv file.
---this file will be sourced right before each requests (it won't be sourced
---multiple times when running all requests in current hurl file)
---@param path string file path of dotenv file
local function register_env_file(path)
    _HURL_GLOBAL_CONFIG.env_file = vim.split(path, ',')
    local updated_env = vim.inspect(_HURL_GLOBAL_CONFIG.env_file)
    utils.log_info('hurl: env file changed to ' .. updated_env)
    utils.notify('hurl: env file changed to ' .. updated_env, vim.log.levels.INFO)
end

-- @param bufnr number? buffer identifier, default to current buffer
---@return string? path
local function select_env_file(bufnr)
  vim.ui.select(utils.find_env_files(), {
    prompt = 'Select env file',
  }, function(item, _idx)
    if item then
      register_env_file(item)
    end
  end)
end

function M.setup()
  -- Show virtual text for Hurl entries
  codelens.setup()

  -- Run request for a range of lines or the entire file
  utils.create_cmd('HurlRunner', function(opts)
    if opts.range ~= 0 then
      run_selection(opts.fargs)
    else
      utils.log_info('hurl: running current file')
      run_current_file(opts.fargs)
    end
  end, { nargs = '*', range = true })

  -- Toggle mode between split and popup
  utils.create_cmd('HurlToggleMode', function()
    local mode = _HURL_GLOBAL_CONFIG.mode
    if mode == 'split' then
      _HURL_GLOBAL_CONFIG.mode = 'popup'
    else
      _HURL_GLOBAL_CONFIG.mode = 'split'
    end
    utils.log_info('hurl: mode changed to ' .. _HURL_GLOBAL_CONFIG.mode)
    utils.notify('hurl: mode changed to ' .. _HURL_GLOBAL_CONFIG.mode, vim.log.levels.INFO)
  end, { nargs = '*', range = true })

  -- Run request at current line if there is a HTTP method
  utils.create_cmd('HurlRunnerAt', function(opts)
    local is_support_hurl = utils.is_nightly() or utils.is_hurl_parser_available
    local result = is_support_hurl and http.find_hurl_entry_positions_in_buffer()
      or http.find_http_verb_positions_in_buffer()
    if result.current > 0 and result.start_line and result.end_line then
      utils.log_info(
        'hurl: running request at line ' .. result.start_line .. ' to ' .. result.end_line
      )
      run_at_lines(result.current, result.current, opts.fargs)
    else
      utils.log_info('hurl: not HTTP method found in the current line' .. result.start_line)
      utils.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
    end
  end, { nargs = '*', range = true })

  -- Run request to current entry if there is a HTTP method
  utils.create_cmd('HurlRunnerToEntry', function(opts)
    local is_support_hurl = utils.is_nightly() or utils.is_hurl_parser_available
    local result = is_support_hurl and http.find_hurl_entry_positions_in_buffer()
      or http.find_http_verb_positions_in_buffer()
    utils.log_info('hurl: running request to entry #' .. vim.inspect(result))
    if result.current > 0 then
      run_at_lines(1, result.current, opts.fargs)
    else
      utils.log_info('hurl: not HTTP method found in the current line' .. result.end_line)
      utils.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
    end
  end, { nargs = '*', range = true })

  -- Set the env file
  utils.create_cmd('HurlSetEnvFile', function(opts)
    local env_file = opts.fargs[1]
    if not env_file then
      utils.log_info('hurl: please provide the env file name')
      utils.notify('hurl: please provide the env file name', vim.log.levels.INFO)
      return
    end

    register_env_file(env_file)
  end, { nargs = '*', range = true })

  -- Select the env file
  utils.create_cmd('HurlSelectEnvFile', function(opts)
    select_env_file()
  end, { nargs = '*', range = true })

  -- Run Hurl in verbose mode
  utils.create_cmd('HurlVerbose', function(opts)
    local filePath = vim.fn.expand('%:p')
    local fromEntry = opts.fargs[1] and tonumber(opts.fargs[1]) or nil
    local toEntry = opts.fargs[2] and tonumber(opts.fargs[2]) or nil

    -- Detect the current entry if fromEntry and toEntry are not provided
    if not fromEntry or not toEntry then
      local is_support_hurl = utils.is_nightly() or utils.is_hurl_parser_available
      local result = is_support_hurl and http.find_hurl_entry_positions_in_buffer()
        or http.find_http_verb_positions_in_buffer()
      if result.current > 0 then
        fromEntry = result.current
        toEntry = result.current
      else
        utils.log_info('hurl: no HTTP method found in the current line')
        utils.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
        return
      end
    end

    run_verbose_command(filePath, fromEntry, toEntry, false)
  end, { nargs = '*', range = true })

  -- Run Hurl in very verbose mode
  utils.create_cmd('HurlVeryVerbose', function(opts)
    local filePath = vim.fn.expand('%:p')
    local fromEntry = opts.fargs[1] and tonumber(opts.fargs[1]) or nil
    local toEntry = opts.fargs[2] and tonumber(opts.fargs[2]) or nil

    -- Detect the current entry if fromEntry and toEntry are not provided
    if not fromEntry or not toEntry then
      local is_support_hurl = utils.is_nightly() or utils.is_hurl_parser_available
      local result = is_support_hurl and http.find_hurl_entry_positions_in_buffer()
        or http.find_http_verb_positions_in_buffer()
      if result.current > 0 then
        fromEntry = result.current
        toEntry = result.current
      else
        utils.log_info('hurl: no HTTP method found in the current line')
        utils.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
        return
      end
    end

    run_verbose_command(filePath, fromEntry, toEntry, true)
  end, { nargs = '*', range = true })

  -- Run Hurl in JSON mode
  utils.create_cmd('HurlJson', function(opts)
    local filePath = vim.fn.expand('%:p')
    local fromEntry = opts.fargs[1] and tonumber(opts.fargs[1]) or nil
    local toEntry = opts.fargs[2] and tonumber(opts.fargs[2]) or nil

    -- Detect the current entry if fromEntry and toEntry are not provided
    if not fromEntry or not toEntry then
      local is_support_hurl = utils.is_nightly() or utils.is_hurl_parser_available
      local result = is_support_hurl and http.find_hurl_entry_positions_in_buffer()
        or http.find_http_verb_positions_in_buffer()
      if result.current > 0 then
        fromEntry = result.current
        toEntry = result.current
      else
        utils.log_info('hurl: no HTTP method found in the current line')
        utils.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
        return
      end
    end

    run_verbose_command(filePath, fromEntry, toEntry, false, { '--json' })
  end, { nargs = '*', range = true })

  utils.create_cmd('HurlSetVariable', function(opts)
    local var_name = opts.fargs[1]
    local var_value = opts.fargs[2]
    if not var_name or not var_value then
      utils.log_info('hurl: please provide the variable name and its value')
      utils.notify('hurl: please provide the variable name and its value', vim.log.levels.INFO)
      return
    end
    _HURL_GLOBAL_CONFIG.global_vars = _HURL_GLOBAL_CONFIG.global_vars or {}
    _HURL_GLOBAL_CONFIG.global_vars[var_name] = var_value
    utils.log_info('hurl: global variable ' .. var_name .. ' set to ' .. var_value)
    utils.notify(
      'hurl: global variable ' .. var_name .. ' set to ' .. var_value,
      vim.log.levels.INFO
    )
  end, { nargs = '*', range = true })

  -- Show all global variables
  utils.create_cmd('HurlManageVariable', function()
    -- Load persisted variables
    local persisted_vars = utils.load_persisted_vars()

    -- Load variables from env files
    local env_vars = {}
    local env_files = _HURL_GLOBAL_CONFIG.find_env_files_in_folders()
    for _, env in ipairs(env_files) do
      if vim.fn.filereadable(env.path) == 1 then
        local vars = utils.parse_env_file(env.path)
        for k, v in pairs(vars) do
          env_vars[k] = v
        end
      end
    end

    -- Merge variables, with persisted taking precedence
    local all_vars = vim.tbl_deep_extend('force', env_vars, persisted_vars)
    _HURL_GLOBAL_CONFIG.global_vars = all_vars

    -- Prepare display lines
    local lines = {}
    if vim.tbl_isempty(all_vars) then
      table.insert(lines, 'No variables set. Press "n" to create a new variable.')
    else
      -- Add env file variables
      for name, value in pairs(env_vars) do
        table.insert(lines, name .. ' = ' .. value .. ' (from env)')
      end
      -- Add persisted variables
      for name, value in pairs(persisted_vars) do
        if not env_vars[name] then
          table.insert(lines, name .. ' = ' .. value)
        endbefore each request (
      end
      table.sort(lines)
    end

    local popup = require('hurl.popup')
    local text_popup = popup.show_text(
      'Hurl.nvim - Variables',
      lines,
      "Press 'q' to close, 'e' to edit, 'n' to create, or 'd' to delete"
    )

    -- Edit variable
    text_popup:map('n', 'e', function()
      local line = vim.api.nvim_get_current_line()
      local var_name = line:match('^([^=]+)=')
      if var_name then
        var_name = var_name:gsub('%s*$', '')
        local new_value = vim.fn.input('Enter new value for ' .. var_name .. ': ')
        if new_value ~= '' then
          persisted_vars[var_name] = new_value
          _HURL_GLOBAL_CONFIG.global_vars[var_name] = new_value
          utils.save_persisted_vars(persisted_vars)
          vim.api.nvim_set_current_line(var_name .. ' = ' .. new_value)
        end
      end
    end)

    -- Create new variable
    text_popup:map('n', 'n', function()
      local var_name = vim.fn.input('Enter new variable name: ')
      if var_name == '' then
        utils.notify('Variable name cannot be empty', vim.log.levels.WARN)
        return
      end

      local var_value = vim.fn.input('Enter variable value: ')
      if var_value == '' then
        utils.notify('Variable value cannot be empty', vim.log.levels.WARN)
        return
      end

      persisted_vars[var_name] = var_value
      _HURL_GLOBAL_CONFIG.global_vars[var_name] = var_value
      utils.save_persisted_vars(persisted_vars)

      -- Update display
      local line_position = vim.tbl_isempty(all_vars) and 0 or -1
      vim.api.nvim_buf_set_lines(0, line_position, -1, false, { var_name .. ' = ' .. var_value })
    end)

    -- Delete variable
    text_popup:map('n', 'd', function()
      local line = vim.api.nvim_get_current_line()
      local var_name = line:match('^([^=]+)=')
      if var_name then
        var_name = var_name:gsub('%s*$', '')
        if env_vars[var_name] then
          utils.notify('Cannot delete variable from env file', vim.log.levels.WARN)
          return
        end
        persisted_vars[var_name] = nil
        _HURL_GLOBAL_CONFIG.global_vars[var_name] = nil
        utils.save_persisted_vars(persisted_vars)
        vim.api.nvim_buf_set_lines(0, vim.fn.line('.') - 1, vim.fn.line('.'), false, {})
      end
    end)
  end, {
    nargs = '*',
    range = true,
  })

  -- Show debug info
  utils.create_cmd('HurlDebugInfo', function()
    -- Get the log file path
    local log_file_path = utils.get_log_file_path()
    local persisted_file_path = utils.get_storage_path()
    local lines =
      { 'Log file path: ' .. log_file_path, 'Persisted file path: ' .. persisted_file_path }
    local persisted_vars = utils.load_persisted_vars()
    if not vim.tbl_isempty(persisted_vars) then
      table.insert(lines, 'Persisted variables:')
      for name, value in pairs(persisted_vars) do
        table.insert(lines, '  ' .. name .. ' = ' .. value)
      end
    end
    local popup = require('hurl.popup')
    popup.show_text('Hurl.nvim - Debug info', lines)
  end, {
    nargs = '*',
    range = true,
  })

  -- TODO: Keep last 10 requests and add key binding to navigate through them
  -- Show last request response
  utils.create_cmd('HurlShowLastResponse', function()
    local history = require('hurl.history')
    local last_response = history.get_last_response()
    if last_response then
      -- Ensure response_time is a number
      last_response.response_time = tonumber(last_response.response_time) or '-'
      local ok, display = pcall(require, 'hurl.' .. (_HURL_GLOBAL_CONFIG.mode or 'split'))
      if not ok then
        utils.notify('Failed to load display module: ' .. display, vim.log.levels.ERROR)
        return
      end
      display.show(last_response, last_response.display_type or 'json')
    else
      utils.notify('No response history available', vim.log.levels.INFO)
    end
  end, {
    nargs = '*',
    range = true,
  })

  -- Run from current line/entry to end of file
  utils.create_cmd('HurlRunnerToEnd', function(opts)
    local is_support_hurl = utils.is_nightly() or utils.is_hurl_parser_available
    local result = is_support_hurl and http.find_hurl_entry_positions_in_buffer()
      or http.find_http_verb_positions_in_buffer()
    if result.current > 0 then
      utils.log_info('hurl: running request from entry ' .. result.current .. ' to end')
      opts.fargs = opts.fargs or {}
      run_at_lines(result.current, nil, opts.fargs)
    else
      utils.log_info('hurl: no HTTP method found in the current line')
      utils.notify('hurl: no HTTP method found in the current line', vim.log.levels.INFO)
    end
  end, { nargs = '*', range = true })

  -- Re-run last Hurl command
  utils.create_cmd('HurlRerun', function()
    if last_from_entry then
      utils.log_info(
        string.format(
          'hurl: re-running last command from entry %d to %s',
          last_from_entry,
          last_to_entry or 'end'
        )
      )
      utils.notify('hurl: re-running last command', vim.log.levels.INFO)

      local opts = {}
      local file_path = vim.fn.expand('%:p')

      -- Reconstruct the command with the stored from_entry and to_entry
      table.insert(opts, file_path)
      table.insert(opts, '--from-entry')
      table.insert(opts, tostring(last_from_entry))
      if last_to_entry then
        table.insert(opts, '--to-entry')
        table.insert(opts, tostring(last_to_entry))
      end

      -- Execute the command
      hurl_runner.execute_hurl_cmd(opts)
    else
      utils.log_info('hurl: no previous command to re-run')
      utils.notify('hurl: no previous command to re-run', vim.log.levels.WARN)
    end
  end, { nargs = 0 })
end

return M

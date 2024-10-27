local utils = require('hurl.utils')
local http = require('hurl.http_utils')
local spinner = require('hurl.spinner')
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

  hurl_runner.execute_hurl_cmd(opts, callback)
end

-- Helper function to run verbose commands in split mode
local function run_verbose_command(filePath, fromEntry, toEntry, isVeryVerbose, additionalArgs)
  hurl_runner.run_hurl_verbose(filePath, fromEntry, toEntry, isVeryVerbose, additionalArgs)
end

function M.setup()
  -- Show virtual text for Hurl entries
  codelens.add_virtual_text_for_hurl_entries()

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
    _HURL_GLOBAL_CONFIG.env_file = vim.split(env_file, ',')
    local updated_env = vim.inspect(_HURL_GLOBAL_CONFIG.env_file)
    utils.log_info('hurl: env file changed to ' .. updated_env)
    utils.notify('hurl: env file changed to ' .. updated_env, vim.log.levels.INFO)
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
    -- Prepare the lines to display in the popup
    local lines = {}
    if not _HURL_GLOBAL_CONFIG.global_vars or vim.tbl_isempty(_HURL_GLOBAL_CONFIG.global_vars) then
      utils.log_info('hurl: no global variables set')
      utils.notify('hurl: no global variables set', vim.log.levels.INFO)
      table.insert(lines, 'No global variables set. Please use :HurlSetVariable to set one.')
    else
      for var_name, var_value in pairs(_HURL_GLOBAL_CONFIG.global_vars) do
        table.insert(lines, var_name .. ' = ' .. var_value)
      end
    end

    local popup = require('hurl.popup')
    local text_popup = popup.show_text(
      'Hurl.nvim - Global variables',
      lines,
      "Press 'q' to close, 'e' to edit, or 'n' to create a variable."
    )

    -- Add e key binding to edit the variable
    text_popup:map('n', 'e', function()
      local line = vim.api.nvim_get_current_line()
      local var_name = line:match('^(.-) =')
      if var_name then
        local new_value = vim.fn.input('Enter new value for ' .. var_name .. ': ')
        _HURL_GLOBAL_CONFIG.global_vars[var_name] = new_value
        vim.api.nvim_set_current_line(var_name .. ' = ' .. new_value)
      end
    end)

    -- Add 'n' to create new variable
    text_popup:map('n', 'n', function()
      local var_name = vim.fn.input('Enter new variable name: ')
      if not var_name or var_name == '' then
        utils.notify('hurl: variable name cannot be empty', vim.log.levels.INFO)
        return
      end

      local var_value = vim.fn.input('Enter new variable value: ')
      if not var_value or var_value == '' then
        utils.notify('hurl: variable value cannot be empty', vim.log.levels.INFO)
        return
      end

      local line_position = -1
      local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)
      if first_line[1] == 'No global variables set. Please use :HurlSetVariable to set one.' then
        -- Clear the buffer if it's empty
        line_position = 0
      end

      vim.cmd('HurlSetVariable ' .. var_name .. ' ' .. var_value)
      -- Append to the last line
      vim.api.nvim_buf_set_lines(0, line_position, -1, false, { var_name .. ' = ' .. var_value })
    end)
  end, {
    nargs = '*',
    range = true,
  })

  -- Show debug info
  utils.create_cmd('HurlDebugInfo', function()
    -- Get the log file path
    local log_file_path = utils.get_log_file_path()
    local lines = { 'Log file path: ' .. log_file_path }
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
      local display = require('hurl.' .. _HURL_GLOBAL_CONFIG.mode)
      display.show(last_response, 'json')
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
end

return M

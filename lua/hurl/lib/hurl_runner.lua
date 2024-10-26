local hurl_parser = require('hurl.lib.hurl_parser')
local utils = require('hurl.utils')
local spinner = require('hurl.spinner')

local M = {}

--- Pretty print body
---@param body string
---@param content_type string
---@return string[]
local function pretty_print_body(body, content_type)
  local formatters = _HURL_GLOBAL_CONFIG.formatters

  if content_type:find('json') then
    utils.log_info('Pretty print JSON body')
    return utils.format(body, 'json') or {}
  elseif content_type:find('html') then
    utils.log_info('Pretty print HTML body')
    return utils.format(body, 'html') or {}
  elseif content_type:find('xml') then
    utils.log_info('Pretty print XML body')
    return utils.format(body, 'xml') or {}
  else
    utils.log_info('Pretty print text body')
    return vim.split(body, '\n')
  end
end

--- Run the hurl command in verbose or very verbose mode
---@param filePath string
---@param fromEntry integer
---@param toEntry integer
---@param isVeryVerbose boolean
function M.run_hurl_verbose(filePath, fromEntry, toEntry, isVeryVerbose)
  local args = { filePath }
  table.insert(args, isVeryVerbose and '--very-verbose' or '--verbose')
  if fromEntry then
    table.insert(args, '--from-entry')
    table.insert(args, tostring(fromEntry))
  end
  if toEntry then
    table.insert(args, '--to-entry')
    table.insert(args, tostring(toEntry))
  end

  -- Inject environment variables from .env files
  local env_files = _HURL_GLOBAL_CONFIG.find_env_files_in_folders()
  for _, env in ipairs(env_files) do
    utils.log_info(
      'hurl: looking for ' .. vim.inspect(_HURL_GLOBAL_CONFIG.env_file) .. ' in ' .. env.path
    )
    if vim.fn.filereadable(env.path) == 1 then
      utils.log_info('hurl: found env file in ' .. env.path)
      table.insert(args, '--variables-file')
      table.insert(args, env.path)
    end
  end

  -- Inject global variables into the command
  if _HURL_GLOBAL_CONFIG.global_vars then
    for var_name, var_value in pairs(_HURL_GLOBAL_CONFIG.global_vars) do
      table.insert(args, '--variable')
      table.insert(args, var_name .. '=' .. var_value)
    end
  end

  local stdout_data = ''
  local stderr_data = ''

  -- Create a new split and buffer for output
  vim.cmd('vsplit')
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

  -- Set a buffer-local keymap to close the buffer with 'q'
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':bd<CR>', { noremap = true, silent = true })

  -- Function to append lines to the buffer
  local function append_to_buffer(lines)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  end

  -- Show the command being run in the buffer
  local command_str = 'hurl ' .. table.concat(args, ' ')
  append_to_buffer({ '```sh', command_str, '```' })

  -- Show the spinner
  spinner.show()

  -- Start the Hurl command asynchronously
  vim.fn.jobstart({ 'hurl', unpack(args) }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        stdout_data = stdout_data .. table.concat(data, '\n')
        append_to_buffer(data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        stderr_data = stderr_data .. table.concat(data, '\n')
        append_to_buffer(data)
      end
    end,
    on_exit = function(_, code)
      -- Hide the spinner
      spinner.hide()

      if code ~= 0 then
        utils.log_info('Hurl command failed with code ' .. code)
        append_to_buffer({ '# Error', stderr_data })
        return
      end

      utils.log_info('Hurl command executed successfully')

      -- Reset the buffer
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

      -- Parse the output using the hurl_parser
      local result = hurl_parser.parse_hurl_output(stderr_data, stdout_data)

      -- Format and display the parsed result
      local output_lines = {}
      for index, entry in ipairs(result.entries) do
        -- Request
        table.insert(output_lines, '# Request #' .. index)
        table.insert(output_lines, '')
        table.insert(output_lines, '## ' .. entry.requestMethod .. ' ' .. entry.requestUrl)
        table.insert(output_lines, '')
        table.insert(output_lines, '## Response: ' .. entry.response.status)

        -- Curl Command
        table.insert(output_lines, '## Curl Command:')
        table.insert(output_lines, '```bash')
        table.insert(output_lines, entry.curlCommand or 'N/A')
        table.insert(output_lines, '```')
        table.insert(output_lines, '')

        -- Only show the body for the last entry
        if index == #result.entries then
          -- Determine the content type for formatting
          local content_type = entry.response.headers['Content-Type']
            or entry.response.headers['content-type']
            or ''
          utils.log_info('Content-Type: ' .. content_type)
          local body_format = 'text'
          if content_type:find('json') then
            body_format = 'json'
          elseif content_type:find('text/html') then
            body_format = 'html'
          elseif content_type:find('application/xml') or content_type:find('text/xml') then
            body_format = 'xml'
          end

          table.insert(output_lines, '### Body:')
          table.insert(output_lines, '```' .. body_format)
          local formatted_body = pretty_print_body(entry.response.body, content_type)
          for _, line in ipairs(formatted_body) do
            table.insert(output_lines, line)
          end
          table.insert(output_lines, '```')
        end

        table.insert(output_lines, '')
        table.insert(output_lines, '### Headers:')
        for key, value in pairs(entry.response.headers) do
          table.insert(output_lines, '- **' .. key .. '**: ' .. value)
        end

        -- Only show captures if there are any
        if entry.captures then
          table.insert(output_lines, '')
          table.insert(output_lines, '### Captures:')
          for key, value in pairs(entry.captures) do
            table.insert(output_lines, '- **' .. key .. '**: ' .. value)
            -- Save captures as global variables in _HURL_GLOBAL_CONFIG if the option is enabled
            if _HURL_GLOBAL_CONFIG.save_captures_as_globals then
              _HURL_GLOBAL_CONFIG.global_vars = _HURL_GLOBAL_CONFIG.global_vars or {}
              _HURL_GLOBAL_CONFIG.global_vars[key] = value
            end
          end
        end

        -- Show timings if any
        if entry.timings then
          table.insert(output_lines, '')
          table.insert(output_lines, '### Timing:')
          for key, value in pairs(entry.timings) do
            table.insert(output_lines, '- **' .. key .. '**: ' .. value)
          end
        end

        table.insert(output_lines, '---')
      end

      -- Append the formatted output to the buffer
      append_to_buffer(output_lines)
    end,
  })
end

return M

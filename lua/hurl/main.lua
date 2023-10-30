--- Unit tests for on_output function
function test_on_output()
  -- Add your test cases here
end

--- Unit tests for request function
function test_request()
  -- Add your test cases here
end

--- Unit tests for run_current_file function
function test_run_current_file()
  -- Add your test cases here
end

--- Unit tests for run_selection function
function test_run_selection()
  -- Add your test cases here
end

--- Unit tests for find_http_verb function
function test_find_http_verb()
  -- Add your test cases here
end

--- Unit tests for find_http_verb_positions_in_buffer function
function test_find_http_verb_positions_in_buffer()
  -- Add your test cases here
end

M.setup = function()
  utils.create_cmd('HurlRunner', function(opts)
    if opts.range ~= 0 then
      run_selection(opts.fargs)
    else
      run_current_file(opts.fargs)
    end
  end, { nargs = '*', range = true })

  utils.create_cmd('HurlRunnerAt', function(opts)
    local result = find_http_verb_positions_in_buffer()
    if result.current > 0 then
      opts.fargs = opts.fargs or {}
      opts.fargs = vim.list_extend(opts.fargs, { '--to-entry', result.current })
      run_current_file(opts.fargs)
    else
      vim.notify('No GET/POST found in the current line')
    end
  end, { nargs = '*', range = true })
end

return M

function M.setup()
  utils.create_cmd('HurlRunner', function(opts)
    if opts.range ~= 0 then
      run_selection(opts.fargs)
    else
      run_current_file(opts.fargs)
    end
  end, { nargs = '*', range = true })

  utils.create_cmd('HurlRunnerAt', function(opts)
    local result = find_http_verb_positions_in_buffer()
    if result.current > 0 then
      opts.fargs = opts.fargs or {}
      opts.fargs = vim.list_extend(opts.fargs, { '--to-entry', result.current })
      run_current_file(opts.fargs)
    else
      vim.notify('No GET/POST found in the current line')
    end
  end, { nargs = '*', range = true })
end

return M

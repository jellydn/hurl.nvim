require('hurl')

local history = require('hurl.history')
local hurl_runner = require('hurl.lib.hurl_runner')
local spinner = require('hurl.spinner')

describe('Hurl runner', function()
  local original_mode
  local original_fixture_vars
  local original_find_env_files
  local original_jobstart
  local original_popup
  local original_spinner_show
  local original_spinner_hide
  local original_update_history

  before_each(function()
    original_mode = _HURL_GLOBAL_CONFIG.mode
    original_fixture_vars = _HURL_GLOBAL_CONFIG.fixture_vars
    original_find_env_files = _HURL_GLOBAL_CONFIG.find_env_files_in_folders
    original_jobstart = vim.fn.jobstart
    original_popup = package.loaded['hurl.popup']
    original_spinner_show = spinner.show
    original_spinner_hide = spinner.hide
    original_update_history = history.update_history

    _HURL_GLOBAL_CONFIG.mode = 'popup'
    _HURL_GLOBAL_CONFIG.fixture_vars = {}
    _HURL_GLOBAL_CONFIG.find_env_files_in_folders = function()
      return {}
    end
    spinner.show = function() end
    spinner.hide = function() end
    hurl_runner.is_running = false
  end)

  after_each(function()
    _HURL_GLOBAL_CONFIG.mode = original_mode
    _HURL_GLOBAL_CONFIG.fixture_vars = original_fixture_vars
    _HURL_GLOBAL_CONFIG.find_env_files_in_folders = original_find_env_files
    vim.fn.jobstart = original_jobstart
    package.loaded['hurl.popup'] = original_popup
    spinner.show = original_spinner_show
    spinner.hide = original_spinner_hide
    history.update_history = original_update_history
    hurl_runner.is_running = false
  end)

  it('should show command errors in the configured popup', function()
    local shown_data
    local history_status
    package.loaded['hurl.popup'] = {
      clear = function() end,
      show = function(data, display_type)
        shown_data = data
        assert.are.equal('markdown', display_type)
      end,
    }
    history.update_history = function(_, status)
      history_status = status
    end
    vim.fn.jobstart = function(_, options)
      options.on_stderr(nil, { 'request failed' })
      options.on_exit(nil, 2)
      return 1
    end

    hurl_runner.execute_hurl_cmd({})

    assert.are.equal('ERROR', shown_data.method)
    assert.are.equal(2, shown_data.status)
    assert.matches('request failed', shown_data.body)
    assert.are.equal('error', history_status)
  end)

  it('should stop running when the configured display cannot load', function()
    local job_started = false
    local spinner_hidden = false
    _HURL_GLOBAL_CONFIG.mode = 'missing'
    spinner.hide = function()
      spinner_hidden = true
    end
    vim.fn.jobstart = function()
      job_started = true
    end

    hurl_runner.execute_hurl_cmd({})

    assert.is_false(hurl_runner.is_running)
    assert.is_true(spinner_hidden)
    assert.is_false(job_started)
  end)
end)

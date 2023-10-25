describe('Hurl.nvim plugin', function()
  it('should be able to load', function()
    local hurl = require('hurl')
    assert.truthy(hurl)

    assert.are.same('popup', _HURL_CFG.mode)
    assert.are.same(false, _HURL_CFG.debug)
  end)

  it('should be able parse the configuration file', function()
    require('hurl').setup({
      debug = true,
      mode = 'split',
    })

    assert.are.same('split', _HURL_CFG.mode)
    assert.are.same(true, _HURL_CFG.debug)
  end)

  describe('Utility functions', function()
    local utils = require('hurl.utils')

    it('should correctly log info', function()
      -- TODO: add a test to check log_info function
    end)

    it('should correctly log error', function()
      -- TODO: add a test to check log_error function
    end)

    it('should correctly get visual selection', function()
      -- TODO: add a test to check get_visual_selection function
    end)

    it('should correctly create tmp file', function()
      -- TODO: add a test to check create_tmp_file function
    end)

    it('should correctly create custom command', function()
      -- TODO: add a test to check create_cmd function
    end)

    it('should correctly format the body of the request', function()
      -- TODO: add a test to check format function
    end)

    it('should correctly render header table', function()
      -- TODO: add a test to check render_header_table function
    end)

    it('should correctly check if the response is json', function()
      -- TODO: add a test to check is_json_response function
    end)

    it('should correctly check if the response is html', function()
      -- TODO: add a test to check is_html_response function
    end)
  end)
end)

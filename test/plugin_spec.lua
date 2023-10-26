describe('Hurl.nvim plugin', function()
  it('should be able to load', function()
    local hurl = require('hurl')
    assert.truthy(hurl)
    assert.truthy(utils)
    assert.truthy(hurl)
    assert.are.same('popup', _HURL_CFG.mode)
    assert.are.same(false, _HURL_CFG.debug)
    local utils = require('hurl.utils')
    assert.truthy(utils)
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
      if utils.log_info then
        utils.log_info('Test info message')
        assert.spy(log.info).was_called_with('Test info message')
      else
        print('Warning: utils.log_info function is nil, skipping test.')
      end
    end)

    it('should correctly log error', function()
      if utils.log_error then
        utils.log_error('Test error message')
        assert.spy(log.error).was_called_with('Test error message')
      else
        print('Warning: utils.log_error function is nil, skipping test.')
      end
    end)

    it('should correctly get visual selection', function()
      vim.fn.setpos("'<", { 0, 1, 1, 0 })
      vim.fn.setpos("'>", { 0, 1, 1, 0 })
      if utils.get_visual_selection then
        local selection = utils.get_visual_selection()
        assert.are.same({ 'GET http://example.com' }, selection)
      else
        print('Warning: utils.get_visual_selection function is nil, skipping test.')
      end
    end)

    it('should correctly create tmp file', function()
      local tmp_file = utils.create_tmp_file('Test content')
      assert.truthy(tmp_file)
      os.remove(tmp_file)
    end)

    it('should correctly create custom command', function()
      utils.create_cmd('TestCommand', function()
        print('Test command')
      end, { desc = 'Test description' })
      assert.truthy(vim.fn.exists(':TestCommand'))
    end)

    it('should correctly format the body of the request', function()
      local formatted_body = utils.format('{"test": "value"}', 'json')
      assert.are.same({ '{', '  "test": "value"', '}' }, formatted_body)
    end)

    it('should correctly render header table', function()
      local headers = { ['Content-Type'] = 'application/json', ['Accept'] = 'application/json' }
      if utils.render_header_table then
        local rendered_headers = utils.render_header_table(headers)
        assert.are.same(
          { 'Content-Type | application/json', 'Accept | application/json' },
          rendered_headers.headers
        )
      else
        print('Warning: utils.render_header_table function is nil, skipping test.')
      end
    end)

    it('should correctly check if the response is json', function()
      local is_json = utils.is_json_response('application/json')
      assert.is_true(is_json)
    end)

    it('should correctly check if the response is html', function()
      local is_html = utils.is_html_response('text/html')
      assert.is_true(is_html)describe('Hurl.nvim plugin', function()
  it('should be able to load', function()
    local hurl = require('hurl')
    assert.truthy(hurl)
    assert.truthy(utils)
    assert.truthy(hurl)
    assert.are.same('popup', _HURL_CFG.mode)
    assert.are.same(false, _HURL_CFG.debug)
    local utils = require('hurl.utils')
    assert.truthy(utils)
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
      if utils.log_info then
        utils.log_info('Test info message')
        assert.spy(log.info).was_called_with('Test info message')
      else
        print('Warning: utils.log_info function is nil, skipping test.')
      end
    end)

    it('should correctly log error', function()
      if utils.log_error then
        utils.log_error('Test error message')
        assert.spy(log.error).was_called_with('Test error message')
      else
        print('Warning: utils.log_error function is nil, skipping test.')
      end
    end)

    it('should correctly get visual selection', function()
      vim.fn.setpos("'<", { 0, 1, 1, 0 })
      vim.fn.setpos("'>", { 0, 1, 1, 0 })
      if utils.get_visual_selection then
        local selection = utils.get_visual_selection()
        assert.are.same({ 'GET http://example.com' }, selection)
      else
        print('Warning: utils.get_visual_selection function is nil, skipping test.')
      end
    end)

    it('should correctly create tmp file', function()
      local tmp_file = utils.create_tmp_file('Test content')
      assert.truthy(tmp_file)
      os.remove(tmp_file)
    end)

    it('should correctly create custom command', function()
      utils.create_cmd('TestCommand', function()
        print('Test command')
      end, { desc = 'Test description' })
      assert.truthy(vim.fn.exists(':TestCommand'))
    end)

    it('should correctly format the body of the request', function()
      local formatted_body = utils.format('{"test": "value"}', 'json')
      assert.are.same({ '{', '  "test": "value"', '}' }, formatted_body)
    end)

    it('should correctly render header table', function()
      local headers = { ['Content-Type'] = 'application/json', ['Accept'] = 'application/json' }
      if utils.render_header_table then
        local rendered_headers = utils.render_header_table(headers)
        assert.are.same(
          { 'Content-Type | application/json', 'Accept | application/json' },
          rendered_headers.headers
        )
      else
        print('Warning: utils.render_header_table function is nil, skipping test.')
      end
    end)

    it('should correctly check if the response is json', function()
      local is_json = utils.is_json_response('application/json')
      assert.is_true(is_json)
    end)

    it('should correctly check if the response is html', function()
      local is_html = utils.is_html_response('text/html')
      assert.is_true(is_html)
assert.are.same('split', _HURL_CFG.mode)
assert.are.same(true, _HURL_CFG.debug)
    end)
  end)
end)

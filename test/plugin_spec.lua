describe('Hurl.nvim plugin', function()
  it('should be able to load', function()
    local hurl = require('hurl')
    assert.truthy(hurl)

    assert.are.same('split', _HURL_GLOBAL_CONFIG.mode)
    assert.are.same(false, _HURL_GLOBAL_CONFIG.debug)
  end)

  it('should be able parse the configuration file', function()
    require('hurl').setup({
      debug = true,
      mode = 'popup',
    })

    assert.are.same('popup', _HURL_GLOBAL_CONFIG.mode)
    assert.are.same(true, _HURL_GLOBAL_CONFIG.debug)
  end)
end)

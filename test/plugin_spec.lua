describe('Hurl.nvim plugin', function()
  it('should be able to load', function()
    local hurl = require('hurl')
    assert.truthy(hurl)

    assert.are.same('split', _HURL_CFG.mode)
    assert.are.same(false, _HURL_CFG.debug)
  end)

  it('should be able parse the configuration file', function()
    require('hurl').setup({
      debug = true,
      mode = 'popup',
    })

    assert.are.same('popup', _HURL_CFG.mode)
    assert.are.same(true, _HURL_CFG.debug)
  end)
end)

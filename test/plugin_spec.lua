local example = require('nvim-plugin-template').example

describe('neovim plugin', function()
  it('work as expect', function()
    local result = example()
    assert.is_true(result)
  end)
end)

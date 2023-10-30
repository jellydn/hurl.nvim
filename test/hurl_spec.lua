local hurl = require('hurl.main')

describe('Hurl wrapper', function()
  it('should be able to load', function()
    assert.truthy(hurl)
  end)

  it('should define a custom command: HurlRunner', function()
    assert.truthy(vim.fn.exists(':HurlRunner'))
  end)

  it('should define a custom command: HurlRunnerAt', function()
    assert.truthy(vim.fn.exists(':HurlRunnerAt'))
  end)
end)

local hurl = require('hurl.main')

describe('Hurl wrapper', function()
  it('should be able to load', function()
    assert.truthy(hurl)
  end)

  it('should define a custom command: HurlRunner', function()
    -- TODO: add a test to check if the command is defined
    assert.falsy(true)
  end)
end)

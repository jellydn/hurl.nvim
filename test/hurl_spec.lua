local hurl = require('hurl.wrapper')

describe('Hurl wrapper', function()
  it('should be able to load', function()
    assert.truthy(hurl)
  end)

  it('should define a custom command: HurlRunner', function()
    -- TODO: add a test to check if the command is defined
    assert.falsy(true)
  end)

  describe('request function', function()
    it('should handle GET requests', function()
      -- TODO: add a test to check GET requests
    end)

    it('should handle POST requests', function()
      -- TODO: add a test to check POST requests
    end)

    it('should handle different response statuses', function()
      -- TODO: add a test to check different response statuses
    end)
  end)

  describe('run_current_file function', function()
    it('should correctly read and execute HTTP requests from a .hurl file', function()
      -- TODO: add a test to check run_current_file function
    end)
  end)

  describe('run_selection function', function()
    it('should correctly read and execute HTTP requests from a selected portion of a .hurl file', function()
      -- TODO: add a test to check run_selection function
    end)
  end)
end)

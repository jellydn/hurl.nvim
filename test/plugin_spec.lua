describe('HurlManageVariable', function()
  before_each(function()
    -- Clear persisted variables before each test
    local utils = require('hurl.utils')
    utils.save_persisted_vars({})
  end)

  it('should load and persist variables', function()
    local utils = require('hurl.utils')
    
    -- Save a test variable
    utils.save_persisted_vars({test_var = 'test_value'})
    
    -- Load the variables
    local vars = utils.load_persisted_vars()
    assert.are.same({test_var = 'test_value'}, vars)
  end)

  it('should parse env files', function()
    local utils = require('hurl.utils')
    
    -- Create a temporary env file
    local tmp_file = vim.fn.tempname()
    local f = io.open(tmp_file, 'w')
    f:write('TEST_VAR=test_value\n')
    f:write('# Comment line\n')
    f:write('ANOTHER_VAR=another_value')
    f:close()
    
    local vars = utils.parse_env_file(tmp_file)
    assert.are.same({
      TEST_VAR = 'test_value',
      ANOTHER_VAR = 'another_value'
    }, vars)
    
    os.remove(tmp_file)
  end)
end)

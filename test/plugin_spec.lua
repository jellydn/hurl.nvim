describe('Variable management', function()
  local variable_store = require('hurl.lib.variable_store')

  before_each(function()
    -- Clear persisted variables before each test
    variable_store.save_persisted_vars({})
  end)

  it('should persist variables between sessions', function()
    -- Set a variable
    local vars = {
      test_var = 'test_value',
    }
    variable_store.save_persisted_vars(vars)

    -- Load variables
    local loaded_vars = variable_store.load_persisted_vars()
    assert.are.same(vars, loaded_vars)
  end)

  it('should load variables from env file', function()
    -- Create a temporary env file
    local temp_file = vim.fn.tempname()
    local f = io.open(temp_file, 'w')
    f:write('TEST_VAR=test_value\n')
    f:write('ANOTHER_VAR=another_value\n')
    f:close()

    -- Parse the env file
    local vars = variable_store.parse_env_file(temp_file)

    -- Clean up
    os.remove(temp_file)

    -- Verify variables were loaded
    assert.are.same({
      TEST_VAR = 'test_value',
      ANOTHER_VAR = 'another_value',
    }, vars)
  end)
end)

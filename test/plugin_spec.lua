describe('Variable Management', function()
  local variable_manager = require('hurl.variable_manager')

  before_each(function()
    -- Clear persistent storage before each test
    variable_manager.save_persistent_vars({})
  end)

  it('should load variables from env file', function()
    -- Create test env file
    local test_env = vim.fn.tempname()
    local f = io.open(test_env, 'w')
    f:write('TEST_VAR=test_value\n')
    f:close()

    -- Configure env file
    require('hurl').setup({
      env_file = { test_env },
    })

    local vars = variable_manager.load_env_vars()
    assert.are.same({ TEST_VAR = 'test_value' }, vars)

    os.remove(test_env)
  end)

  it('should persist variables between sessions', function()
    local test_vars = { test_var = 'test_value' }

    -- Save variables
    assert.is_true(variable_manager.save_persistent_vars(test_vars))

    -- Load variables
    local loaded_vars = variable_manager.load_persistent_vars()
    assert.are.same(test_vars, loaded_vars)
  end)

  it('should handle both env and persistent variables', function()
    -- Create test env file
    local test_env = vim.fn.tempname()
    local f = io.open(test_env, 'w')
    f:write('ENV_VAR=env_value\n')
    f:close()

    -- Set up env file and persistent vars
    require('hurl').setup({
      env_file = { test_env },
    })

    variable_manager.save_persistent_vars({ PERS_VAR = 'pers_value' })

    local env_vars = variable_manager.load_env_vars()
    local pers_vars = variable_manager.load_persistent_vars()

    assert.are.same({ ENV_VAR = 'env_value' }, env_vars)
    assert.are.same({ PERS_VAR = 'pers_value' }, pers_vars)

    os.remove(test_env)
  end)
end)

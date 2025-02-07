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

describe('Variable Management', function()
  local utils = require('hurl.utils')
  
  before_each(function()
    -- Clear persisted variables
    utils.save_persisted_vars({})
    -- Reset global vars
    _HURL_GLOBAL_CONFIG.global_vars = {}
  end)

  it('should load variables from env file', function()
    -- Create test env file
    local test_env = vim.fn.tempname()
    local f = io.open(test_env, 'w')
    f:write('TEST_VAR=test_value\n')
    f:close()

    local vars = utils.parse_env_file(test_env)
    assert.are.same({ TEST_VAR = 'test_value' }, vars)
    os.remove(test_env)
  end)

  it('should persist variables between sessions', function()
    local test_vars = { test_var = 'test_value' }
    assert.is_true(utils.save_persisted_vars(test_vars))
    
    local loaded_vars = utils.load_persisted_vars()
    assert.are.same(test_vars, loaded_vars)
  end)

  it('should merge env and persisted variables', function()
    -- Create test env file
    local test_env = vim.fn.tempname()
    local f = io.open(test_env, 'w')
    f:write('ENV_VAR=env_value\n')
    f:close()

    -- Add persisted variable
    utils.save_persisted_vars({ PERS_VAR = 'pers_value' })

    local env_vars = utils.parse_env_file(test_env)
    local pers_vars = utils.load_persisted_vars()
    
    local merged = vim.tbl_deep_extend('force', env_vars, pers_vars)
    assert.are.same({
      ENV_VAR = 'env_value',
      PERS_VAR = 'pers_value'
    }, merged)

    os.remove(test_env)
  end)
end)
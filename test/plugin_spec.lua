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

  it('should define the environment file selection command', function()
    assert.are.equal(2, vim.fn.exists(':HurlSelectEnvFile'))
  end)

  it('should reject an invalid environment file pattern without throwing', function()
    local original_pattern = _HURL_GLOBAL_CONFIG.env_pattern
    _HURL_GLOBAL_CONFIG.env_pattern = '['

    local ok, err = pcall(vim.cmd, 'HurlSelectEnvFile')

    _HURL_GLOBAL_CONFIG.env_pattern = original_pattern
    assert.is_true(ok, err)
  end)

  it('should search for environment files from the working directory', function()
    local original_find = vim.fs.find
    local original_select = vim.ui.select
    local search_options
    vim.fs.find = function(_, options)
      search_options = options
      return { 'vars.env' }
    end
    vim.ui.select = function() end

    local ok, err = pcall(vim.cmd, 'HurlSelectEnvFile')

    vim.fs.find = original_find
    vim.ui.select = original_select
    assert.is_true(ok, err)
    assert.are.equal(vim.fn.getcwd(), search_options.path)
    assert.is_false(search_options.upward)
  end)
end)

describe('Variable Management', function()
  local utils = require('hurl.utils')
  local original_env_file

  before_each(function()
    original_env_file = _HURL_GLOBAL_CONFIG.env_file
    -- Clear persisted variables
    utils.save_persisted_vars({})
    -- Reset global vars
    _HURL_GLOBAL_CONFIG.global_vars = {}
  end)

  after_each(function()
    _HURL_GLOBAL_CONFIG.env_file = original_env_file
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
      PERS_VAR = 'pers_value',
    }, merged)

    os.remove(test_env)
  end)

  it('should preserve selected absolute env file paths', function()
    local test_env = vim.fn.tempname()
    _HURL_GLOBAL_CONFIG.env_file = { test_env }

    local env_files = utils.find_env_files_in_folders()

    assert.are.equal(1, #env_files)
    assert.are.equal(vim.fs.normalize(test_env), env_files[1].path)
  end)
end)

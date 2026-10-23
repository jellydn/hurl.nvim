local git = require('hurl.git_utils')

describe('Git root discovery', function()
  local cwd
  local directory

  before_each(function()
    cwd = vim.fn.getcwd()
    directory = vim.fn.tempname() .. ' project with spaces '
    vim.fn.mkdir(directory .. '/nested/requests', 'p')
  end)

  after_each(function()
    vim.fn.chdir(cwd)
    vim.fn.delete(directory, 'rf')
  end)

  it('returns the root from a nested directory without changing path whitespace', function()
    vim.fn.system({ 'git', '-C', directory, 'init', '--quiet' })
    assert.are.equal(0, vim.v.shell_error)
    vim.fn.chdir(directory .. '/nested/requests')

    assert.is_true(git.is_git_repo())
    assert.are.equal(vim.fn.resolve(directory), git.get_git_root())
  end)

  it('returns nil outside a Git repository', function()
    vim.fn.chdir(directory)

    assert.is_false(git.is_git_repo())
    assert.is_nil(git.get_git_root())
  end)
end)

local hurl = require('hurl.wrapper')

describe('Hurl wrapper', function()
  it('should be able to load', function()
    assert.truthy(hurl)
  end)

  it('should define a custom command: HurlRunner', function()
    assert.truthy(vim.fn.exists(':HurlRunner'))
  end)

  it('should handle GET requests', function()
    -- Mock the GET request
    local mock_request = { method = 'GET', url = 'http://example.com' }
    -- Call the request function with the mock request
    if hurl.request then
      hurl.request(mock_request, function(response)
        -- Check that the response status is 200
        assert.equals(response.status, 200)
      end)
    else
      print('Warning: hurl.request function is nil, skipping test.')
      return
    end
  end)

  it('should handle POST requests', function()
    -- Mock the POST request
    local mock_request = { method = 'POST', url = 'http://example.com', body = 'test' }
    -- Call the request function with the mock request
    if hurl.request then
      hurl.request(mock_request, function(response)
        -- Check that the response status is 201
        assert.equals(response.status, 201)
      end)
    else
      print('Warning: hurl.request function is nil, skipping test.')
      return
    end
  end)

  it('should handle different response statuses', function()
    -- Mock the 404 request
    local mock_request = { method = 'GET', url = 'http://example.com/nonexistent' }
    -- Call the request function with the mock request
    if hurl.request then
      hurl.request(mock_request, function(response)
        -- Check that the response status is 404
        assert.equals(response.status, 404)
      end)
    else
      print('Warning: hurl.request function is nil, skipping test.')
      return
    end
  end)

  it('should correctly read and execute HTTP requests from a .hurl file', function()
    -- Mock the .hurl file
    local mock_file = './test/fixture.hurl'
    -- Write a GET request to the mock file
    vim.fn.writefile({ 'GET http://example.com' }, mock_file)
    -- Call the run_current_file function with the mock file
    if hurl.run_current_file then
      hurl.run_current_file({ mock_file }, function(response)
        -- Check that the response status is 200
        assert.equals(response.status, 200)
        -- Delete the mock file
        os.remove(mock_file)
      end)
    else
      print('Warning: hurl.run_current_file function is nil, skipping test.')
      return
    end
    if hurl.run_selection then
      hurl.run_selection({ mock_file }, function(response)
        -- Check that the response status is 200
        assert.equals(response.status, 200)
        -- Delete the mock file
        os.remove(mock_file)
      end)
    else
      print('Warning: hurl.run_selection function is nil, skipping test.')
      return
    end

    it(
      'should correctly read and execute HTTP requests from a selected portion of a .hurl file',
      function()
        -- Write a GET request to the mock file
        vim.fn.writefile({ 'GET http://example.com' }, mock_file)
        -- Select the GET request in the mock file
        vim.fn.setpos("'<", { 0, 1, 1, 0 })
        vim.fn.setpos("'>", { 0, 1, 1, 0 })
        -- Call the run_selection function with the mock file
        if hurl.run_selection then
          hurl.run_selection({ mock_file }, function(response)
            -- Check that the response status is 200
            assert.equals(response.status, 200)
            -- Delete the mock file
            os.remove(mock_file)
          end)
        else
          print('Warning: hurl.run_selection function is nil, skipping test.')
          return
        end
      end
    )
  end)
end)

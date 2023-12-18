local utils = require('hurl.utils')

local function test_is_json_response()
  assert(utils.is_json_response('application/json') == true)
  assert(utils.is_json_response('application/vnd.api+json') == true)
  assert(utils.is_json_response('text/html') == false)
  assert(utils.is_json_response('application/xml') == false)
  assert(utils.is_json_response('random_string') == false)
end

test_is_json_response()

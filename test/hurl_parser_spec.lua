local hurl_parser = require('hurl.lib.hurl_parser')

describe('Hurl Parser', function()
  it('should parse hurl output correctly', function()
    local stderr = [[
* Executing 1/2 entries
* ------------------------------------------------------------------------------
* Executing entry 1
*
* Cookie store:
*
* Request:
* GET https://dogapi.dog/api/v2/breeds
*
* Request can be run with the following curl command:
* curl 'https://dogapi.dog/api/v2/breeds'
*
> GET /api/v2/breeds HTTP/2
> Host: dogapi.dog
> Accept: */*
> User-Agent: hurl/5.0.1
>
* Request body:
*
* Response: (received 8035 bytes in 1352 ms)
*
< HTTP/2 200
< cache-control: max-age=0, private, must-revalidate
< content-type: application/vnd.api+json; charset=utf-8
< etag: W/"6e98619b9e70f8f3f0fe1739d6e7e48f"
< referrer-policy: strict-origin-when-cross-origin
< vary: Accept, Origin
< x-content-type-options: nosniff
< x-download-options: noopen
< x-frame-options: SAMEORIGIN
< x-permitted-cross-domain-policies: none
< x-request-id: 3a8f5671-3330-434d-94cf-bf286620de69
< x-runtime: 0.030100
< x-xss-protection: 0
< date: Thu, 24 Oct 2024 14:13:35 GMT
<
* Captures:
* id: 68f47c5a-5115-47cd-9849-e45d3c378f12
*
* Response body:
* Bytes <7b2264617461223a5b7b226964223a2236386634376335612d353131352d343763642d393834392d653435643363333738663132222c2274797065223a226272...>
*
* Timings:
* begin: 2024-10-24 14:13:34.437445 UTC
* end: 2024-10-24 14:13:35.790169750 UTC
* namelookup: 1985 µs
* connect: 49931 µs
* app_connect: 887533 µs
* pre_transfer: 887930 µs
* start_transfer: 1195453 µs
* total: 1352357 µs
*
]]
    local stdout =
      [[{"data":[{"id":"68f47c5a-5115-47cd-9849-e45d3c378f12","type":"breed","attributes":{"name":"Caucasian Shepherd Dog","description":"The Caucasian Shepherd Dog is a large and powerful breed of dog from the Caucasus Mountains region. These dogs are large in size, with a thick double coat to protect them from the cold. They have a regal bearing, with a proud and confident demeanor. They are highly intelligent and loyal, making them excellent guard dogs. They are courageous and alert, with an instinct to protect their family and property. They are highly trainable, but require firm and consistent training.","life":{"max":20,"min":15},"male_weight":{"max":90,"min":50},"female_weight":{"max":70,"min":45},"hypoallergenic":false},"relationships":{"group":{"data":{"id":"8000793f-a1ae-4ec4-8d55-ef83f1f644e5","type":"group"}}}}]}]]

    local result = hurl_parser.parse_hurl_output(stderr, stdout)

    assert.are.equal(1, #result.entries)
    local entry = result.entries[1]
    assert.are.equal('GET', entry.requestMethod)
    assert.are.equal('https://dogapi.dog/api/v2/breeds', entry.requestUrl)
    assert.are.equal('HTTP/2 200', entry.response.status)
    assert.are.equal(
      'application/vnd.api+json; charset=utf-8',
      entry.response.headers['content-type']
    )
    assert.are.equal('max-age=0, private, must-revalidate', entry.response.headers['cache-control'])
    assert.are.equal('Thu, 24 Oct 2024 14:13:35 GMT', entry.response.headers['date'])
    assert.are.equal('1352357 µs', entry.timings['total'])
    assert.are.equal('49931 µs', entry.timings['connect'])
    assert.are.equal('1985 µs', entry.timings['namelookup'])
    assert.are.equal('68f47c5a-5115-47cd-9849-e45d3c378f12', entry.captures['id'])
  end)

  it('should parse hurl output with error correctly', function()
    local stderr = [[
* ------------------------------------------------------------------------------
* Executing entry 2
error: Undefined variable
  --> /Users/huynhdung/Projects/research/vscode-hurl-runner/example/dogs.hurl:9:40
   |
 9 | GET https://dogapi.dog/api/v2/breeds/{{id}}
   |                                        ^^ you must set the variable id
   |
]]
    local stdout = ''

    local result = hurl_parser.parse_hurl_output(stderr, stdout)

    assert.are.equal(1, #result.entries)
    local entry = result.entries[1]
    assert.are.equal('Undefined variable', entry.error:match('^[^\n]+'))
    assert.is_true(entry.error:find('you must set the variable id') ~= nil)
  end)

  it('should parse verbose output with multiple entries correctly', function()
    local stderr = [[
* Executing 2/2 entries
* ------------------------------------------------------------------------------
* Executing entry 1
*
* Cookie store:
*
* Request:
* GET https://dogapi.dog/api/v2/breeds
*
* Request can be run with the following curl command:
* curl 'https://dogapi.dog/api/v2/breeds'
*
> GET /api/v2/breeds HTTP/2
> Host: dogapi.dog
> Accept: */*
> User-Agent: hurl/5.0.1
>
* Response: (received 8035 bytes in 1272 ms)
*
< HTTP/2 200
< cache-control: max-age=0, private, must-revalidate
< content-type: application/vnd.api+json; charset=utf-8
< etag: W/"6e98619b9e70f8f3f0fe1739d6e7e48f"
< referrer-policy: strict-origin-when-cross-origin
< vary: Accept, Origin
< x-content-type-options: nosniff
< x-download-options: noopen
< x-frame-options: SAMEORIGIN
< x-permitted-cross-domain-policies: none
< x-request-id: 8080162a-0b2c-4972-b6ef-6fe9ecdb44fc
< x-runtime: 0.021512
< x-xss-protection: 0
< date: Thu, 24 Oct 2024 14:17:28 GMT
<
* Captures:
* id: 68f47c5a-5115-47cd-9849-e45d3c378f12
*
* ------------------------------------------------------------------------------
* Executing entry 2
*
* Cookie store:
*
* Request:
* GET https://dogapi.dog/api/v2/breeds/68f47c5a-5115-47cd-9849-e45d3c378f12
*
* Request can be run with the following curl command:
* curl 'https://dogapi.dog/api/v2/breeds/68f47c5a-5115-47cd-9849-e45d3c378f12'
*
> GET /api/v2/breeds/68f47c5a-5115-47cd-9849-e45d3c378f12 HTTP/2
> Host: dogapi.dog
> Accept: */*
> User-Agent: hurl/5.0.1
>
* Response: (received 915 bytes in 241 ms)
*
< HTTP/2 200
< cache-control: max-age=0, private, must-revalidate
< content-type: application/vnd.api+json; charset=utf-8
< etag: W/"50468c5bd4e22a8856dda44b0c5ab6d9"
< referrer-policy: strict-origin-when-cross-origin
< vary: Accept, Origin
< x-content-type-options: nosniff
< x-download-options: noopen
< x-frame-options: SAMEORIGIN
< x-permitted-cross-domain-policies: none
< x-request-id: eea473d8-8502-40ab-ac91-e5598e43e85e
< x-runtime: 0.011166
< x-xss-protection: 0
< date: Thu, 24 Oct 2024 14:17:28 GMT
<
]]
    local stdout = [[
{"data":{"id":"68f47c5a-5115-47cd-9849-e45d3c378f12","type":"breed","attributes":{"name":"Caucasian Shepherd Dog","description":"The Caucasian Shepherd Dog is a large and powerful breed of dog from the Caucasus Mountains region. These dogs are large in size, with a thick double coat to protect them from the cold. They have a regal bearing, with a proud and confident demeanor. They are highly intelligent and loyal, making them excellent guard dogs. They are courageous and alert, with an instinct to protect their family and property. They are highly trainable, but require firm and consistent training.","life":{"max":20,"min":15},"male_weight":{"max":90,"min":50},"female_weight":{"max":70,"min":45},"hypoallergenic":false},"relationships":{"group":{"data":{"id":"8000793f-a1ae-4ec4-8d55-ef83f1f644e5","type":"group"}}}},"links":{"self":"https://dogapi.dog/api/v2/breeds/68f47c5a-5115-47cd-9849-e45d3c378f12"}}
]]

    local result = hurl_parser.parse_hurl_output(stderr, stdout)

    assert.are.equal(2, #result.entries)

    -- Check first entry
    local entry1 = result.entries[1]
    assert.are.equal('GET', entry1.requestMethod)
    assert.are.equal('https://dogapi.dog/api/v2/breeds', entry1.requestUrl)
    assert.are.equal('HTTP/2 200', entry1.response.status)
    assert.are.equal(
      'application/vnd.api+json; charset=utf-8',
      entry1.response.headers['content-type']
    )
    assert.are.equal('68f47c5a-5115-47cd-9849-e45d3c378f12', entry1.captures['id'])

    -- Check second entry
    local entry2 = result.entries[2]
    assert.are.equal('GET', entry2.requestMethod)
    assert.are.equal(
      'https://dogapi.dog/api/v2/breeds/68f47c5a-5115-47cd-9849-e45d3c378f12',
      entry2.requestUrl
    )
    assert.are.equal('HTTP/2 200', entry2.response.status)
    assert.are.equal(
      'application/vnd.api+json; charset=utf-8',
      entry2.response.headers['content-type']
    )
    assert.is_true(entry2.response.body:find('"name":"Caucasian Shepherd Dog"') ~= nil)
  end)

  it(
    'should parse captures correctly when there is no space between timings and captures',
    function()
      local stderr = [[
* Executing entry 1
* Timings:
* begin: 2024-10-24 18:41:33.558372 UTC
* end: 2024-10-24 18:41:35.129397875 UTC
* namelookup: 1446 µs
* connect: 49514 µs
* app_connect: 930193 µs
* pre_transfer: 930448 µs
* start_transfer: 1524375 µs
* total: 1570744 µs
* Captures:
* id: 68f47c5a-5115-47cd-9849-e45d3c378f12
* name: Caucasian Shepherd Dog
]]
      local stdout = ''

      local result = hurl_parser.parse_hurl_output(stderr, stdout)

      assert.are.equal(1, #result.entries)
      local entry = result.entries[1]
      -- __AUTO_GENERATED_PRINT_VAR_START__
      print([==[function#function entry:]==], vim.inspect(entry)) -- __AUTO_GENERATED_PRINT_VAR_END__
      assert.are.equal('68f47c5a-5115-47cd-9849-e45d3c378f12', entry.captures['id'])
      assert.are.equal('Caucasian Shepherd Dog', entry.captures['name'])
    end
  )
end)

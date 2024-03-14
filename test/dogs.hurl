# Get breeds and then get the first breed
GET https://dogapi.dog/api/v2/breeds

HTTP 200

[Captures]
id: jsonpath "$.data[0].id"

GET https://dogapi.dog/api/v2/breeds/{{id}}

HTTP 200

[Asserts]
jsonpath "$.data.id" == {{id}}

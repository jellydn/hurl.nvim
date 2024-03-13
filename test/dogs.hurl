# [Sweep Rules] Fixed missing commit message in test/dogs.hurl

Added a descriptive commit message to provide context and explanation for the changes made in the file.# Added commit message

GET https://dogapi.dog/api/v2/breeds

HTTP 200

[Captures]
id: jsonpath "$.data[0].id"

GET https://dogapi.dog/api/v2/breeds/{{id}}

HTTP 200

[Asserts]
jsonpath "$.data.id" == {{id}}

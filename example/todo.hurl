# Get all todos
GET https://wattpm-demo.fly.dev/express/api/todo

HTTP 200
[Asserts]
jsonpath "$.status" == "success"
header "server" contains "Fly"


# Throw error if text is not provided
POST https://wattpm-demo.fly.dev/express/api/todo
Content-Type: application/json
{}
HTTP 400
[Asserts]
jsonpath "$.status" == "error"
jsonpath "$.message" == "Text is required"

# Create a new todo
POST https://wattpm-demo.fly.dev/express/api/todo
Content-Type: application/json
{
  "text": "Call Express API from hurl.nvim at {{now}}"
}
HTTP 201

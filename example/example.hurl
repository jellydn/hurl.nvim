# Get manga details with manga_id on vars.env file
GET https://api.mangadex.org/statistics/manga/{{manga_id}}

HTTP 200
[Asserts]
jsonpath "$.result" == "ok"
header "server" contains "MangaDex"

GET https://google.com

HTTP 301
[Asserts]
xpath "string(//title)" == "301 Moved"

GET https://www.google.com

HTTP 200
[Asserts]
xpath "string(//title)" == "Google"

GET https://example.org

HTTP 200
[Captures]
csrf_token: xpath "string(//meta[@name='_csrf_token']/@content)"

POST https://highstorm.app/api/v1/events/user.onboarded
Authorization: Bearer {{jwt_token}}
{
  "event": "hurl.nvim onboarded",
  "content": "User has sent their first event",
  "metadata": {
      "user_id": "1",
      "name": "Dung Huynh"
  }
}
HTTP 200

[Asserts]
header "server" contains "Vercel"

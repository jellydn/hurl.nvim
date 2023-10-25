GET https://api.mangadex.org/statistics/manga/8b34f37a-0181-4f0b-8ce3-01217e9a602c

GET https://example.org

HTTP 200
[Captures]
csrf_token: xpath "string(//meta[@name='_csrf_token']/@content)"

POST https://hurl.dev/api/feedback
{
  "name": "Huynh, Dung",
  "feedback": "Hurl is awesome!"
}
HTTP 404

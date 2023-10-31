GET https://api.mangadex.org/statistics/manga/{{manga_id}}

GET https://example.org

HTTP 200
[Captures]
csrf_token: xpath "string(//meta[@name='_csrf_token']/@content)"

POST https://hurl.dev/api/feedback
{
  "name": "Dung Huynh",
  "feedback": "Hurl is awesome!"
}
HTTP 404

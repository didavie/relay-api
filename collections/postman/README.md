# Postman collection

[`relay-api.postman_collection.json`](relay-api.postman_collection.json) holds every v1 request, grouped by key kind, plus the sandbox-only simulator calls.

1. In Postman: **Import** > select the file.
2. Open the collection **Variables** and set:
   - `apiKey`: your key. Start with a sandbox key (`rb_sbx_...`) from [relaysandbox.didavie.com](https://relaysandbox.didavie.com).
   - `baseUrl`: `https://relaysandbox.didavie.com/api/v1` (default) or `https://relaypartner.didavie.com/api/v1` for live keys.
   - `trackingCode`, `quoteId`, `driverId`: copy them from earlier answers.
3. Authentication is set on the collection (`Bearer {{apiKey}}`).

Keep the key in the collection's *current value* only, so it is not synced or exported.

Bruno and Insomnia import this collection, or the OpenAPI file [`openapi/openapi.json`](../../openapi/openapi.json), directly.

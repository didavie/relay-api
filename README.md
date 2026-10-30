# Relay API

Public reference and examples for the Relay API v1, by Didavie.

Relay is a delivery platform. The API lets online shops and delivery agencies price a delivery, create it, track it, and receive signed webhooks when its status changes.

[Version française](README.fr.md)

| | |
| --- | --- |
| Base URL (production) | `https://relaypartner.didavie.com/api/v1` |
| Base URL (sandbox) | `https://relaysandbox.didavie.com/api/v1` |
| Format | JSON over HTTPS |
| Authentication | `Authorization: Bearer <key>` or `X-API-Key: <key>` |
| OpenAPI | [`openapi/openapi.json`](openapi/openapi.json), also served at `https://relaypartner.didavie.com/api/v1/openapi.json` |
| Full reference | [relaypartner.didavie.com/en/developers](https://relaypartner.didavie.com/en/developers) |

## Contents

| Path | What it holds |
| --- | --- |
| [`openapi/openapi.json`](openapi/openapi.json) | OpenAPI 3.0 description of every endpoint, schema and webhook payload |
| [`docs/authentication.md`](docs/authentication.md) | Key kinds, environments, scopes |
| [`docs/shop-checkout.md`](docs/shop-checkout.md) | Shop keys: from the cart price to the delivery |
| [`docs/sandbox.md`](docs/sandbox.md) | Test without a Relay account ([français](docs/sandbox.fr.md)) |
| [`docs/webhooks.md`](docs/webhooks.md) | Events, payloads, signature, retries |
| [`docs/errors.md`](docs/errors.md) | Error envelope and every error code |
| [`docs/limits.md`](docs/limits.md) | Rate limits and daily caps |
| [`examples/curl`](examples/curl) | Runnable curl walkthroughs for shop and agency keys |
| [`webhooks`](webhooks) | Signature verifiers for Node.js, PHP and Python, with tests |
| [`collections/postman`](collections/postman) | Postman collection (also imports into Bruno and Insomnia) |

## Quick start

1. Create a free account on [relaysandbox.didavie.com](https://relaysandbox.didavie.com) and create a shop key (`rb_sbx_...`).
2. Call the API:

```bash
export RELAY_API_KEY=rb_sbx_xxxxxxxxxxxx
BASE=https://relaysandbox.didavie.com/api/v1

# Who am I
curl -s "$BASE/me" -H "Authorization: Bearer $RELAY_API_KEY"

# Price for an address (returns a quote_id valid about 15 minutes)
curl -s -G "$BASE/pricing/estimate" -H "Authorization: Bearer $RELAY_API_KEY" \
  --data-urlencode "delivery_address=Haie Vive, Cotonou"

# Create the delivery at that price
curl -s -X POST "$BASE/packages" \
  -H "Authorization: Bearer $RELAY_API_KEY" -H "Content-Type: application/json" \
  -d '{
    "platform_order_id": "WC-1001",
    "quote_id": "<quote_id from the estimate>",
    "delivery_latitude": 6.3654,
    "delivery_longitude": 2.4183,
    "client_name": "Awa Dossou",
    "client_phone": "+2290197000002",
    "client_address": "Haie Vive, Cotonou"
  }'
```

3. Follow the delivery with `GET /packages/{tracking_code}`, or receive webhooks (see [docs/webhooks.md](docs/webhooks.md)). In the sandbox, the delivery moves on its own and the simulator can force any status.

The full walkthroughs are in [`examples/curl/shop.sh`](examples/curl/shop.sh) and [`examples/curl/agency.sh`](examples/curl/agency.sh).

## Keys

| Key | Who | Prefix | Where to create it |
| --- | --- | --- | --- |
| Shop | A shop approved on Relay, to connect its website | `rb_live_` | Relay Partners > Shop > Connect my website |
| Agency | A delivery agency on Relay Partners | `relay_pk_live_` | Agency dashboard > Developers |
| Sandbox | Anyone, no Relay account | `rb_sbx_`, `relay_pk_sbx_` | [relaysandbox.didavie.com](https://relaysandbox.didavie.com) |

Live keys use the production base URL. To test, use a sandbox key: sandbox keys work only on the sandbox. Keep keys on your server, never in browser or mobile app code. Details: [docs/authentication.md](docs/authentication.md).

## Endpoints

| Method | Path | Shop keys | Agency keys | Purpose |
| --- | --- | --- | --- | --- |
| GET | `/me` | Yes | Yes | Who the key belongs to |
| GET | `/pricing/estimate` | Yes | Yes | Delivery price for a trip (shops get a `quote_id`) |
| POST | `/packages` | Yes | Yes | Create a delivery (idempotent) |
| GET | `/packages` | Yes | Yes | List deliveries (`updated_since` for shops) |
| GET | `/packages/{tracking_code}` | Yes | Yes | One delivery |
| PATCH | `/packages/{tracking_code}` | Yes | No | Edit until pickup |
| GET | `/packages/{tracking_code}/status` | Yes | Yes | Light status for polling |
| PATCH | `/packages/{tracking_code}/cancel` | Yes | Yes | Cancel before pickup |
| POST | `/packages/{tracking_code}/assign` | No | Yes | Assign one of your drivers |
| GET | `/drivers` | No | Yes | Agency drivers |
| GET | `/zones` | No | Yes | Active delivery zones |
| GET | `/pricing` | No | Yes | Credit unit price |

Every response uses the same envelope:

```json
{ "success": true, "data": { "tracking_code": "RB042917", "status": "registered" } }
```

```json
{ "success": false, "error": "Package not found or not accessible with this API key.", "code": "NOT_FOUND" }
```

Amounts are whole numbers in the currency given by `currency` (for example `XOF`); field names ending in `_fcfa` carry those amounts.

## Ready-made integrations

| Integration | Repository |
| --- | --- |
| WooCommerce plugin | [didavie/relay-woocommerce](https://github.com/didavie/relay-woocommerce) |
| n8n community nodes | [didavie/n8n-nodes-relay](https://github.com/didavie/n8n-nodes-relay) |

## Use the OpenAPI file

- **Postman**: File > Import > select `openapi/openapi.json`, or the collection in [`collections/postman`](collections/postman).
- **Bruno or Insomnia**: import the OpenAPI file or the Postman collection.
- **Code generation**: any OpenAPI 3.0 generator works, for example `npx @openapitools/openapi-generator-cli generate -i openapi/openapi.json -g typescript-fetch -o client`.

## Development

```bash
npm ci
npm run lint     # OpenAPI lint (Redocly), JSON checks
npm test         # Node.js webhook verifier tests
npm run test:php     # PHP verifier tests
npm run test:python  # Python verifier tests
```

See [CONTRIBUTING.md](CONTRIBUTING.md). Changes are listed in [CHANGELOG.md](CHANGELOG.md).

## Support

- E-mail: relay@didavie.com
- Documentation issues: [GitHub issues](https://github.com/didavie/relay-api/issues)
- Security issues: see [SECURITY.md](SECURITY.md)

## License

The examples, verifiers, collection and documentation in this repository are released under the [MIT License](LICENSE). Relay and the Relay API are services of Didavie; using the API is subject to the Relay terms.

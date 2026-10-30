# Webhooks

Relay sends a signed `POST` with a JSON body to your https URL when a delivery changes status. Webhooks are faster than polling and are the way to keep orders up to date.

## Set up

| Key kind | Where to set the URL and get the signing secret |
| --- | --- |
| Shop | Relay Partners > Shop > Connect my website. The secret (`whsec_...`) is shown once. |
| Agency | Agency dashboard > Developers > Webhooks. Choose the events there. |
| Sandbox | [relaysandbox.didavie.com](https://relaysandbox.didavie.com) > Webhook (an inbox URL is offered for quick tests) |

## Request

```http
POST /hooks/relay HTTP/1.1
Content-Type: application/json
User-Agent: Relay-Webhook/1.0
X-Relay-Event: package.delivered
X-Relay-Signature: t=1760440800,v1=5f2c...
```

### Shop events

| Event | When |
| --- | --- |
| `package.picked_up` | The driver picked up the package |
| `package.delivered` | The package was delivered to the customer |
| `package.cancelled` | The package was cancelled |
| `package.failed` | Delivery problem, or the package is returned |
| `webhook.test` | Test sent from the settings page |

```json
{
  "id": "evt_8f14e45fceea167a5a36dedd4bea2543",
  "event": "package.delivered",
  "created_at": "2026-10-14T11:20:00Z",
  "data": {
    "package_id": "3f6c1d2e-8a4b-4c7d-9e1f-0a2b3c4d5e6f",
    "tracking_code": "RB042917",
    "platform_order_id": "WC-1001",
    "status": "delivered",
    "previous_status": "in_transit",
    "assigned_driver_name": "Koffi M.",
    "picked_up_at": "2026-10-14T10:40:00Z",
    "delivered_at": "2026-10-14T11:20:00Z",
    "delivery_fee_fcfa": 1000,
    "currency": "XOF"
  }
}
```

`data` is the same package object as the API returns, without the pickup and delivery codes and QR codes and without `tracking_url`, plus `previous_status`. `id` is unique for each event.

### Agency events

`package.created`, `package.assigned`, `package.picked_up`, `package.delivered`, `package.cancelled`, `package.issue_reported`. Each fires once per status change, for the events you subscribed to.

```json
{
  "event": "package.delivered",
  "timestamp": "2026-03-14T12:30:00Z",
  "package": {
    "id": "3f6c1d2e-8a4b-4c7d-9e1f-0a2b3c4d5e6f",
    "tracking_code": "RB042917",
    "status": "delivered",
    "delivered_at": "2026-03-14T12:30:00Z"
  },
  "agency_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

The payload schemas are in [`openapi/openapi.json`](../openapi/openapi.json) under `x-webhooks`.

## Verify the signature

`X-Relay-Signature: t=<unix seconds>,v1=<hex signature>`

1. Read the **raw** request body, before any JSON parsing.
2. Split the header on `,` and read `t` and `v1`.
3. Compute `HMAC-SHA256(secret, t + "." + raw_body)` and hex-encode it.
4. Compare it with `v1` in constant time (`hash_equals` in PHP, `crypto.timingSafeEqual` in Node.js, `hmac.compare_digest` in Python).
5. Reject the request when `|now - t|` is more than 300 seconds (replay protection).
6. Skip an event `id` you already handled: the same event can arrive more than once.

Ready-to-use verifiers with tests: [Node.js](../webhooks/node/verify.mjs), [PHP](../webhooks/php/verify.php), [Python](../webhooks/python/relay_webhook.py). They share one [test vector](../webhooks/fixtures/vector.json).

Use the secret exactly as given: shop secrets start with `whsec_`, agency secrets are 64 hex characters. Both are used as the HMAC key as is.

## Answer and retries

| | Shop webhooks | Agency webhooks |
| --- | --- | --- |
| Answer within | 5 seconds, with any 2xx | 10 seconds, with any 2xx |
| Retries | after 30 s, 5 min and 30 min (4 attempts in total) | up to 5 retries: 5 s, 25 s, 2 min, 10 min, 30 min |
| Redirects | not followed: use the final URL | use the final URL |

Answer fast, then do the work (queue it). If your endpoint is down for longer than the retries, use `GET /packages?updated_since=...` (shop keys) or `GET /packages` (agency keys) to catch up.

## Common mistakes

- Verifying a re-serialised body. Frameworks often parse JSON before your code runs: use the raw body (`express.raw()`, `request.get_data()`, `file_get_contents('php://input')`).
- A firewall, CDN rule or security plugin that blocks `POST` requests without cookies.
- Server clock far from real time: the 300-second check then fails. Keep NTP on.

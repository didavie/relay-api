# Authentication

Every request carries an API key, in one of two headers:

```http
Authorization: Bearer rb_sbx_xxxxxxxxxxxx
```

```http
X-API-Key: rb_sbx_xxxxxxxxxxxx
```

The `Bearer` scheme is case-insensitive. A request without a key gets `401 UNAUTHORIZED`.

## Key kinds

| Kind | Prefix | Created by | Where |
| --- | --- | --- | --- |
| Shop, live | `rb_live_` + 48 hex characters | The owner of a shop approved on Relay | Relay Partners > Shop > Connect my website |
| Agency, live | `relay_pk_live_` | A delivery agency | Agency dashboard > Developers |
| Sandbox, shop | `rb_sbx_` + 48 hex characters | Anyone | [relaysandbox.didavie.com](https://relaysandbox.didavie.com) |
| Sandbox, agency | `relay_pk_sbx_` + 64 hex characters | Anyone | Same |

- A shop key acts only for the shop that created it. An agency key acts only for its agency.
- Keys are shown once. Relay keeps only a fingerprint: if you lose a key, create a new one and revoke the old one.
- A shop can have at most 3 active keys, and so can a sandbox account. A revoked key stops working at once.
- Keep keys on your server. Never put them in browser code, a mobile app or a public repository.

## Environments

| Key | Base URL | Data |
| --- | --- | --- |
| `rb_live_`, `relay_pk_live_` | `https://relaypartner.didavie.com/api/v1` | Real deliveries |
| `rb_sbx_`, `relay_pk_sbx_` | `https://relaysandbox.didavie.com/api/v1` | Fake deliveries that move on their own |

Build and test against the sandbox, then switch to a live key. Sandbox keys are refused by production (`401 INVALID_KEY_FORMAT`, with a message that points to the sandbox), and the sandbox refuses live keys.

Shop keys also have a dry run: send `"test": true` in `POST /packages` to validate the request and compute the price without creating anything.

## Who am I

`GET /me` works with every valid key and needs no scope. Use it to check a key.

Shop key:

```json
{
  "success": true,
  "data": {
    "key_type": "shop",
    "key_id": "5a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d",
    "mode": "live",
    "shop": { "id": "7c6b5a4d-3e2f-4a1b-9c8d-7e6f5a4b3c2d", "name": "Boutique Awa", "shop_code": "SHP-0042", "country": "BJ" },
    "scopes": ["packages:read", "packages:write", "tracking:read", "pricing:read"]
  }
}
```

Agency key: the agency (`id`, `agency_name`, `agency_code`, `credits_balance`, `verification_status`) and the key `scopes`.

## Scopes (agency keys)

Agency keys get scopes when they are created. A call without the needed scope answers `403 INSUFFICIENT_SCOPE`.

| Scope | Access |
| --- | --- |
| `packages:read` | List and read packages |
| `packages:write` | Create, assign and cancel packages; list drivers |
| `tracking:read` | Track packages by tracking code |
| `zones:read` | Read delivery zones |
| `pricing:read` | Credit price and fee estimates |

Shop keys always have `packages:read`, `packages:write`, `tracking:read` and `pricing:read`. Agency-only routes (`/drivers`, `/zones`, `/pricing`, `/packages/{tracking_code}/assign`) answer `403 SHOP_KEY_NOT_ALLOWED` to a shop key.

## If a key leaks

Revoke it right away on the page where it was created and create a new one. Then update every place that used it.

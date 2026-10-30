# Errors

Every error uses the same envelope. Check `success` first, then branch on `code`: it is stable, while `error` is a readable message that can change.

```json
{
  "success": false,
  "error": "The quote has expired. Ask for a new price.",
  "code": "QUOTE_EXPIRED",
  "details": { "expires_at": "2026-10-14T10:15:00Z" }
}
```

`details` is optional and adds context, for example the limit that was reached.

## HTTP status

| Status | Meaning |
| --- | --- |
| 400 | The request is not valid, or the action cannot be done (for example no price for the route) |
| 401 | Key missing, malformed, unknown or revoked |
| 402 | Agency subscription or credits needed |
| 403 | The key is not allowed to do this |
| 404 | Not found, or not visible with this key |
| 405 | Method not allowed for this key kind |
| 409 | Conflict with the current state (status, quote, idempotency) |
| 422 | The request is valid but cannot be served (no price, country not served) |
| 429 | A limit was reached: wait for `Retry-After` |
| 500 | Server error: retry with back-off |
| 503 | The API is switched off for now: retry later |

## Authentication codes (all keys)

| Status | Code | What it means |
| --- | --- | --- |
| 401 | `UNAUTHORIZED` | No key in `Authorization` or `X-API-Key` |
| 401 | `INVALID_KEY_FORMAT` | Not a Relay key, or a sandbox key sent to production (or the reverse) |
| 401 | `TEST_KEY_RETIRED` | An old test key (`rb_test_`, `relay_pk_test_`) sent to production: test keys are retired, use a sandbox key |
| 401 | `INVALID_API_KEY` | Unknown, expired or revoked key |
| 403 | `INSUFFICIENT_SCOPE` | Agency key without the scope the route needs |
| 403 | `SHOP_KEY_NOT_ALLOWED` | Agency-only route called with a shop key |
| 403 | `SHOP_NOT_APPROVED` | The shop is not, or no longer, approved by Relay |
| 403 | `SHOP_INACTIVE` | The shop is deactivated: its keys no longer work. Contact support. |
| 403 | `SHOP_PAUSED` | Relay paused this shop's keys. Contact support. |
| 429 | `RATE_LIMIT_EXCEEDED` | Too many requests (see [limits.md](limits.md)) |
| 503 | `API_DISABLED` | The shop API is switched off for now |

## Request codes

| Status | Code | What it means |
| --- | --- | --- |
| 400 | `INVALID_BODY` | The body is not a JSON object |
| 400 | `VALIDATION_ERROR` | A field is missing or not valid; the message names it |
| 400 | `INVALID_PHONE` | The phone number is not valid. Use the international format (`+229...`) or the local format. |
| 404 | `NOT_FOUND` | Unknown tracking code or package for this key |
| 405 | `METHOD_NOT_ALLOWED` | `PATCH /packages/{tracking_code}` with an agency key (shop keys only) |

## Pricing and quotes

| Status | Code | What it means |
| --- | --- | --- |
| 400 | `QUOTE_INVALID` | `quote_id` is unknown for this shop |
| 409 | `QUOTE_EXPIRED` | The quote is older than about 15 minutes: get a new estimate |
| 409 | `QUOTE_USED` | The quote was already used for another delivery |
| 409 | `QUOTE_MISMATCH` | Pickup or delivery point differs from the quote (200 m tolerance) |
| 422 | `PRICING_UNAVAILABLE` | No delivery price for this route (agency keys get 400) |
| 400 | `PRICING_ZERO_FEE` | Agency grid prices the route at zero: adjust the zone pricing |
| 400 | `OUT_OF_ZONE` | Destination outside the agency zones, and the agency refuses out-of-zone deliveries |
| 400 | `ROUTE_COUNTRY_UNKNOWN` | The trip is outside a country served by Relay (related codes are possible) |
| 422 | `COUNTRY_NOT_SERVED` | Relay does not deliver in this country yet (`details.country_code`) |

## Delivery state

| Status | Code | What it means |
| --- | --- | --- |
| 409 | `CANNOT_EDIT` | Shop key: the package was picked up, it can no longer be edited |
| 409 | `CANNOT_CANCEL` | Shop key: the package was picked up, it can no longer be cancelled |
| 409 | `INVALID_STATUS` | Agency key: the action is not possible in the current status (cancel, assign after pickup) |
| 409 | `INTAKE_REVIEW_REQUIRED` | Agency key: the package must be accepted in the dashboard before a driver is assigned |
| 409 | `IDEMPOTENCY_CONFLICT` | Agency key: `Idempotency-Key` and `external_order_id` point to different packages |

## Agency credits and fleet

| Status | Code | What it means |
| --- | --- | --- |
| 402 | `INSUFFICIENT_CREDITS` | Not enough credits to create the package (`details.credits_required`, `details.credits_balance`). On assign, the same code comes with status 400. |
| 400 or 402 | `AGENCY_SUBSCRIPTION_REQUIRED` | The agency plan does not allow this |
| 400 or 402 | `AGENCY_CREDITS_REQUIRED` | The agency has no credits left to dispatch |
| 403 | `MINIMUM_DRIVERS_REQUIRED` | Assigning needs a minimum number of active drivers |
| 403 | `FORBIDDEN` | The agency is not allowed to act on this package |

## Shop limits

| Status | Code | What it means |
| --- | --- | --- |
| 429 | `DAILY_LIMIT` | Daily delivery limit reached (`details.limit`, `Retry-After: 3600`) |
| 429 | `PENDING_LIMIT` | 30 deliveries are already waiting for a driver |

## Server

| Status | Code | What it means |
| --- | --- | --- |
| 500 | `INTERNAL_ERROR` | Unexpected error. Retry with back-off; if it keeps happening, write to relay@didavie.com with the time and the request path (never the key). |

## Sandbox only

| Status | Code | What it means |
| --- | --- | --- |
| 409 | `INVALID_TRANSITION` | The simulator only moves a delivery forward |
| 400 | `WEBHOOK_NOT_CONFIGURED` | No webhook URL is saved for this key kind |

# Limits

## Request rate

| Limit | Value | Applies to |
| --- | --- | --- |
| Per API key | 120 requests per minute | All keys |
| Per client IP | 300 requests per minute | All requests, valid key or not |
| Estimates | 60 per minute per key | Shop keys, `GET /pricing/estimate` |

Over a limit, the API answers `429 RATE_LIMIT_EXCEEDED` with these headers:

```http
Retry-After: 23
X-RateLimit-Limit: 120
X-RateLimit-Remaining: 0
```

`details` repeats `limit`, `window_seconds` and `retry_after`. Windows are fixed one-minute windows. Wait `Retry-After` seconds before retrying.

## Shop deliveries

| Limit | Value | Error |
| --- | --- | --- |
| New shop | 20 deliveries a day, for the first 30 days or until 20 successful deliveries | `429 DAILY_LIMIT` (`details.limit`, `Retry-After: 3600`) |
| Established shop | 200 deliveries a day | `429 DAILY_LIMIT` |
| Waiting for a driver | 30 deliveries at once | `429 PENDING_LIMIT` |

Dry runs (`"test": true`) do not count.

## Sandbox

60 requests per minute per key, 50 deliveries a day, 30 open at once, 3 keys per account, 5 webhook tests per minute. Accounts are deleted after 30 days.

## Sizes

| Field | Limit |
| --- | --- |
| `Idempotency-Key` header, `external_order_id` | 128 characters |
| `platform_order_id` | 100 characters |
| `GET /packages` `limit` | 100 (default 50) |
| Agency `client_address`, `delivery_address` | at least 10 characters |
| Agency `description` | 500 characters |
| Shop `weight_kg` | up to 30 |

## Retry advice

- Retry `429` after `Retry-After`, and `500` or network errors with exponential back-off.
- `POST /packages` is safe to retry with the same `platform_order_id` (shop keys) or `Idempotency-Key` / `external_order_id` (agency keys).
- Do not retry other `4xx` answers unchanged: fix the request first.

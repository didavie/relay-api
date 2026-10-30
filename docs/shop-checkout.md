# Shop keys: from the cart to the delivery

The most common shop integration: show the Relay price in the cart, then create the delivery at that price once the order is paid.

## 1. Price at checkout

Call `GET /pricing/estimate` with the customer's GPS point, or with the address text when you have no GPS point.

```bash
curl -s -G https://relaypartner.didavie.com/api/v1/pricing/estimate \
  -H "Authorization: Bearer $RELAY_API_KEY" \
  --data-urlencode "delivery_lat=6.3654" --data-urlencode "delivery_lng=2.4183" \
  --data-urlencode "weight_kg=1"
```

```json
{
  "success": true,
  "data": {
    "quote_id": "c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f",
    "expires_at": "2026-10-14T10:15:00Z",
    "price_fcfa": 1000,
    "price_type": "fixed",
    "currency": "XOF",
    "distance_km": 3.4,
    "eta_minutes": 25
  }
}
```

| Parameter | Notes |
| --- | --- |
| `delivery_lat`, `delivery_lng` | The customer's point. Without them, `price_type` is `from`: the lowest possible price, the final price is set at create. |
| `delivery_address` | Instead of the point: the address text. Relay finds the point in the shop's country, near the pickup, and answers `geocoded` and `geocoded_address`. |
| `pickup_lat`, `pickup_lng` | Optional. Default: the pickup point saved on the Connect my website page. |
| `weight_kg` | Optional. Default: the saved weight. |
| `delivery_type` | `standard`. `express` is accepted and answered as standard with a `delivery_type_note`. |

Show `price_fcfa` to the customer (for example "1,000 F", or "from 1,000 F" when `price_type` is `from`). Keep `quote_id` with the cart: it is valid about 15 minutes (`expires_at`) and can be used once. `eta_minutes` is a rough estimate (15 minutes plus 3 minutes per km). At most 60 estimates per minute per key.

## 2. Create the delivery when the order is paid

```bash
curl -s -X POST https://relaypartner.didavie.com/api/v1/packages \
  -H "Authorization: Bearer $RELAY_API_KEY" -H "Content-Type: application/json" \
  -d '{
    "platform_order_id": "WC-1001",
    "quote_id": "c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f",
    "delivery_latitude": 6.3654,
    "delivery_longitude": 2.4183,
    "client_name": "Awa Dossou",
    "client_phone": "+2290197000002",
    "client_address": "Haie Vive, rue 12.045, Cotonou",
    "description": "2 t-shirts",
    "weight_kg": 1,
    "value_fcfa": 15000
  }'
```

- Required: `platform_order_id`, `client_name`, `client_phone`, `client_address`.
- `platform_order_id` is your order number. Sending it again returns the same delivery with `idempotent: true` and HTTP 200: retries never create duplicates.
- With the same `quote_id` and the same points (200 m tolerance), the price is the one the customer saw. An expired, used or mismatched quote answers `409 QUOTE_EXPIRED`, `QUOTE_USED` or `QUOTE_MISMATCH`: ask for a new estimate.
- `delivery_payer`: `merchant` (the shop pays) or `recipient` (the customer pays the driver on delivery). Default: the shop setting.
- `delivery_fee_fcfa` can raise the computed price, never lower it. The minimum delivery fee always applies.
- `metadata` is a free JSON object kept with the delivery.
- `"test": true` validates everything and computes the price, but creates nothing, calls no driver and counts toward no limit.

The answer (201 on a new delivery) holds `tracking_code`, `tracking_url` (the public tracking page for your customer), the pickup and delivery codes (`code_retrait`, `code_livraison`) and the final price `delivery_fee_fcfa`.

## 3. Follow it

- Webhooks: `package.picked_up`, `package.delivered`, `package.cancelled`, `package.failed` (see [webhooks.md](webhooks.md)).
- Or polling: `GET /packages/{tracking_code}/status`, or `GET /packages?updated_since=<time>` to get only the deliveries that changed. The list answer adds `server_time`: send it as the next `updated_since`.

## 4. Edit or cancel

Until the driver picks the package up:

- `PATCH /packages/{tracking_code}` with only the fields to change (contact, address, points, description, weight, value, instructions, `metadata`, a higher `delivery_fee_fcfa`). The assigned driver, if any, is told.
- `PATCH /packages/{tracking_code}/cancel` with an optional `{"reason": "..."}`. Cancelling is free.

After pickup they answer `409 CANNOT_EDIT` and `409 CANNOT_CANCEL`.

## Prices and costs

Sending deliveries through the API is free: there is no API fee, you pay the normal delivery price. The price is the same as in the Relay app for the same trip (price grid, time-of-day pricing, current promotion).

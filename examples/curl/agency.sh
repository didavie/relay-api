#!/usr/bin/env bash
# Agency key walkthrough: account, zones, drivers, estimate, create, assign, cancel.
# Requires curl and jq.
#
#   RELAY_API_KEY=relay_pk_sbx_xxxxxxxxxxxx ./agency.sh
#
# Sandbox keys (relay_pk_sbx_) use the sandbox; live and test keys use production.
set -euo pipefail

: "${RELAY_API_KEY:?Set RELAY_API_KEY to an agency key (relay_pk_sbx_, relay_pk_test_ or relay_pk_live_)}"
case "$RELAY_API_KEY" in
  relay_pk_sbx_*) BASE="${RELAY_API_BASE:-https://relaysandbox.didavie.com/api/v1}" ;;
  relay_pk_*) BASE="${RELAY_API_BASE:-https://relaypartner.didavie.com/api/v1}" ;;
  *) echo "This script is for agency keys (relay_pk_...)." >&2; exit 1 ;;
esac
AUTH="Authorization: Bearer ${RELAY_API_KEY}"

echo "1. Agency, credit balance and scopes"
curl -sS "$BASE/me" -H "$AUTH" | jq .

echo "2. Delivery zones and credit price"
curl -sS "$BASE/zones" -H "$AUTH" | jq .
curl -sS "$BASE/pricing" -H "$AUTH" | jq .

echo "3. Fee for a route (pickup and delivery points are required)"
curl -sS -G "$BASE/pricing/estimate" -H "$AUTH" \
  --data-urlencode "pickup_lat=6.3703" --data-urlencode "pickup_lng=2.3912" \
  --data-urlencode "delivery_lat=6.3654" --data-urlencode "delivery_lng=2.4183" \
  --data-urlencode "weight_kg=2.5" --data-urlencode "assignment_mode=own_fleet" | jq .

echo "4. Create a package (Idempotency-Key makes retries safe)"
ORDER_ID="ORD-$(date +%s)"
CREATED=$(curl -sS -X POST "$BASE/packages" -H "$AUTH" -H "Content-Type: application/json" \
  -H "Idempotency-Key: $ORDER_ID" \
  -d "$(jq -n --arg order "$ORDER_ID" '{
        external_order_id: $order,
        client_name: "Jean Dupont",
        client_phone: "+22991234567",
        client_address: "Rue des Fleurs, Cotonou",
        delivery_address: "Marché Dantokpa, Cotonou",
        pickup_latitude: 6.3703,
        pickup_longitude: 2.3912,
        delivery_latitude: 6.3654,
        delivery_longitude: 2.4183,
        weight_kg: 2.5,
        assignment_mode: "own_fleet",
        is_cod: false
      }')")
echo "$CREATED" | jq .
TRACKING=$(echo "$CREATED" | jq -r '.data.tracking_code')

echo "5. Assign one of your drivers"
DRIVER_ID=$(curl -sS -G "$BASE/drivers" -H "$AUTH" --data-urlencode "active=true" | jq -r '.data.drivers[0].driver_id // empty')
if [ -n "$DRIVER_ID" ]; then
  curl -sS -X POST "$BASE/packages/$TRACKING/assign" -H "$AUTH" -H "Content-Type: application/json" \
    -d "$(jq -n --arg d "$DRIVER_ID" '{driver_id: $d}')" | jq .
else
  echo "No active driver: skipped."
fi

echo "6. Status, then cancel"
curl -sS "$BASE/packages/$TRACKING/status" -H "$AUTH" | jq .
curl -sS -X PATCH "$BASE/packages/$TRACKING/cancel" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"cancellation_reason": "Customer cancelled"}' | jq .

#!/usr/bin/env bash
# Shop key walkthrough: estimate at checkout, create the delivery with the quote,
# read it, edit it, cancel it. Requires curl and jq.
#
#   RELAY_API_KEY=rb_sbx_xxxxxxxxxxxx ./shop.sh
#
# Sandbox keys (rb_sbx_) use the sandbox; live keys (rb_live_) use production.
set -euo pipefail

: "${RELAY_API_KEY:?Set RELAY_API_KEY to a shop key (rb_sbx_ or rb_live_)}"
case "$RELAY_API_KEY" in
  rb_sbx_*) BASE="${RELAY_API_BASE:-https://relaysandbox.didavie.com/api/v1}" ;;
  rb_live_*) BASE="${RELAY_API_BASE:-https://relaypartner.didavie.com/api/v1}" ;;
  *) echo "This script is for shop keys (rb_...)." >&2; exit 1 ;;
esac
AUTH="Authorization: Bearer ${RELAY_API_KEY}"

echo "1. Who am I"
curl -sS "$BASE/me" -H "$AUTH" | jq .

echo "2. Price for the customer's address (quote valid about 15 minutes)"
QUOTE=$(curl -sS -G "$BASE/pricing/estimate" -H "$AUTH" \
  --data-urlencode "delivery_address=Haie Vive, Cotonou")
echo "$QUOTE" | jq .
QUOTE_ID=$(echo "$QUOTE" | jq -r '.data.quote_id')
LAT=$(echo "$QUOTE" | jq -r '.data.delivery_latitude')
LNG=$(echo "$QUOTE" | jq -r '.data.delivery_longitude')

echo "3. Create the delivery at the quoted price (same order id = same delivery)"
ORDER_ID="WC-$(date +%s)"
CREATED=$(curl -sS -X POST "$BASE/packages" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg order "$ORDER_ID" --arg quote "$QUOTE_ID" --argjson lat "$LAT" --argjson lng "$LNG" '{
        platform_order_id: $order,
        quote_id: $quote,
        delivery_latitude: $lat,
        delivery_longitude: $lng,
        client_name: "Awa Dossou",
        client_phone: "+2290197000002",
        client_address: "Haie Vive, Cotonou",
        description: "2 t-shirts",
        weight_kg: 1
      }')")
echo "$CREATED" | jq .
TRACKING=$(echo "$CREATED" | jq -r '.data.tracking_code')

echo "4. Read it"
curl -sS "$BASE/packages/$TRACKING" -H "$AUTH" | jq .

echo "5. Light status (for polling)"
curl -sS "$BASE/packages/$TRACKING/status" -H "$AUTH" | jq .

echo "6. Edit it (allowed until pickup)"
curl -sS -X PATCH "$BASE/packages/$TRACKING" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"special_instructions": "Call on arrival at the blue gate"}' | jq .

echo "7. List the deliveries changed in the last hour"
SINCE=$(date -u -v-1H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)
curl -sS -G "$BASE/packages" -H "$AUTH" --data-urlencode "updated_since=$SINCE" --data-urlencode "limit=10" | jq .

echo "8. Cancel it (free until pickup)"
curl -sS -X PATCH "$BASE/packages/$TRACKING/cancel" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"reason": "Order cancelled by the customer"}' | jq .

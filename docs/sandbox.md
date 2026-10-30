# Test with the sandbox

The sandbox at [relaysandbox.didavie.com](https://relaysandbox.didavie.com) is a free copy of the Relay API with fake deliveries. You do not need a Relay account.

[Version française](sandbox.fr.md)

## Get a key

1. Create an account on [relaysandbox.didavie.com](https://relaysandbox.didavie.com) and confirm your e-mail address.
2. Open **API keys** and create a key:
   - **Shop** (`rb_sbx_...`): websites, WooCommerce, n8n and other no-code tools.
   - **Agency** (`relay_pk_sbx_...`): agency integrations (create with `client_address` and `delivery_address`, drivers, zones).
3. Copy the key: it is shown once.

## Call it

Base URL: `https://relaysandbox.didavie.com/api/v1`. Same paths, fields, error codes and signed webhooks as production.

```bash
curl -s https://relaysandbox.didavie.com/api/v1/me -H "Authorization: Bearer rb_sbx_xxxxxxxxxxxx"
```

`/me` and price answers add `"sandbox": true`. Tracking codes start with `SB`.

| Tool | Where the sandbox key goes |
| --- | --- |
| Your own code, curl | `Authorization: Bearer rb_sbx_...`, base URL `https://relaysandbox.didavie.com/api/v1` |
| [WooCommerce plugin](https://github.com/didavie/relay-woocommerce) | WooCommerce > Settings > Shipping > Relay > API key. Keep the default API address. |
| [n8n nodes](https://github.com/didavie/n8n-nodes-relay) | Relay API credential > API Key, environment *Automatic* |
| Postman | The `apiKey` variable of [the collection](../collections/postman) (its `baseUrl` already points to the sandbox) |

The plugins recognise the `rb_sbx_` and `relay_pk_sbx_` prefixes and call the sandbox on their own.

## How deliveries move

- **Auto-advance** (on by default): a driver is assigned at once, the package is picked up after about 2 minutes and delivered after about 5 minutes. Each step sends the webhook production would send.
- **Simulator**: force a status from the **Deliveries** page, or with the API:

```bash
curl -s -X POST https://relaysandbox.didavie.com/api/v1/sandbox/packages/SB042917/simulate \
  -H "Authorization: Bearer rb_sbx_xxxxxxxxxxxx" -H "Content-Type: application/json" \
  -d '{"status": "delivered"}'
```

`status` can be `driver_assigned`, `picked_up`, `out_for_delivery`, `delivered`, `problem` or `cancelled`. Moves go forward only (`409 INVALID_TRANSITION` otherwise). `{"auto_advance": false}` pauses the automatic steps for that package, `true` resumes them.

## Webhooks in the sandbox

On the **Webhook** page, set your https URL for each key kind and copy the signing secret. No server yet? Use the inbox URL the page gives you: the sandbox keeps the last 20 webhooks it receives there and checks their signatures.

`POST /sandbox/webhook/test` sends a `webhook.test` event to the URL saved for the key's kind (5 tests per minute).

## What differs from production

- Prices come from a fixed sandbox formula.
- No real drivers, zones or assignment: `/drivers`, `/zones` and `/pricing` answer with a fake driver and a fake zone.
- Limits are lower: 60 requests per minute per key, 50 deliveries a day, 30 open at once (`DAILY_LIMIT`, `PENDING_LIMIT`).
- Accounts and their data are deleted after 30 days. Accounts not confirmed within 48 hours are deleted.
- Sandbox keys are refused by production, and production keys are refused by the sandbox.

## Going live

1. Get your shop approved on Relay, then create a live key (`rb_live_...`) on Relay Partners > Shop > Connect my website.
2. Replace the sandbox key with the live key. Change the base URL to `https://relaypartner.didavie.com/api/v1` if your own code sets it (the plugins switch on their own).
3. Set the production webhook URL and paste the new signing secret.

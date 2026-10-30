# curl examples

Two runnable walkthroughs. Both need `curl` and `jq`, and pick the base URL from the key prefix.

| Script | Key | What it does |
| --- | --- | --- |
| [`shop.sh`](shop.sh) | Shop (`rb_sbx_`, `rb_live_`) | `/me`, estimate by address, create with the quote, read, status, edit, list with `updated_since`, cancel |
| [`agency.sh`](agency.sh) | Agency (`relay_pk_sbx_`, `relay_pk_live_`) | `/me`, zones, credit price, estimate, create with `Idempotency-Key`, assign a driver, status, cancel |

```bash
RELAY_API_KEY=rb_sbx_xxxxxxxxxxxx ./shop.sh
RELAY_API_KEY=relay_pk_sbx_xxxxxxxxxxxx ./agency.sh
```

Start with a sandbox key: the scripts create a delivery and cancel it at the end. `RELAY_API_BASE` overrides the base URL.

Keep keys out of your shell history on shared machines, for example with `read -rs RELAY_API_KEY && export RELAY_API_KEY`.

# Webhook signature verifiers

Small, dependency-free functions that check the `X-Relay-Signature` header of a Relay webhook. Copy the one for your language into your project.

| Language | File | Function | Test |
| --- | --- | --- | --- |
| Node.js 18+ | [`node/verify.mjs`](node/verify.mjs) | `verifyRelaySignature(rawBody, header, secret)` | `node --test node/verify.test.mjs` |
| PHP 7.4+ | [`php/verify.php`](php/verify.php) | `relay_verify_signature( $raw_body, $header, $secret )` | `php php/test.php` |
| Python 3.8+ | [`python/relay_webhook.py`](python/relay_webhook.py) | `verify_relay_signature(raw_body, header, secret)` | `cd python && python3 -m unittest` |

Each function returns `true` only when a `v1` signature matches `HMAC-SHA256(secret, "<t>.<raw body>")` and `t` is within 300 seconds of now. All three are tested against the same [test vector](fixtures/vector.json), whose secret is a placeholder.

Pass the raw body exactly as received. After verifying, skip events whose `id` you already handled, answer with a 2xx quickly, and do the work in the background. The full rules are in [docs/webhooks.md](../docs/webhooks.md).

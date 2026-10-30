# Contributing

Thank you for helping improve the Relay API documentation and examples.

## What belongs here

- Fixes and clarifications to the guides in `docs/`.
- New examples (languages, frameworks) and improvements to the webhook verifiers.
- Reports of a difference between this documentation and the live API.

`openapi/openapi.json` is published from the API source: open an issue for a change to it instead of editing the file.

## Before you start

- Open an [issue](https://github.com/didavie/relay-api/issues) for anything larger than a typo.
- Never include a real API key, webhook secret or customer data. Use placeholders like `rb_sbx_xxxxxxxxxxxx` and sandbox keys from [relaysandbox.didavie.com](https://relaysandbox.didavie.com) for testing.
- Security problems go through [SECURITY.md](SECURITY.md), not public issues.

## Checks

Node.js 20 or later is required; PHP and Python are needed to run their verifier tests.

```bash
npm ci
npm run lint   # OpenAPI lint (Redocly) and JSON checks
npm test              # Node.js verifier tests
npm run test:php      # PHP verifier tests
npm run test:python   # Python verifier tests
```

The CI runs the same checks, plus `shellcheck` on the curl scripts.

## Style

- Plain, short sentences. English in `docs/`, with French pages named `*.fr.md`.
- Examples must work against the sandbox as written.
- Use clear commit messages in the imperative mood, for example `docs: explain updated_since paging`.

By contributing, you agree that your work is released under the [MIT License](LICENSE).

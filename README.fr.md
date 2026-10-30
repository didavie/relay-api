# Relay API

Référence publique et exemples de l'API Relay v1, par Didavie.

Relay est une plateforme de livraison. L'API permet aux boutiques en ligne et aux agences de livraison de chiffrer une livraison, la créer, la suivre et recevoir des webhooks signés à chaque changement de statut.

[English version](README.md)

| | |
| --- | --- |
| URL de base (production) | `https://relaypartner.didavie.com/api/v1` |
| URL de base (sandbox) | `https://relaysandbox.didavie.com/api/v1` |
| Format | JSON sur HTTPS |
| Authentification | `Authorization: Bearer <clé>` ou `X-API-Key: <clé>` |
| OpenAPI | [`openapi/openapi.json`](openapi/openapi.json) |
| Référence complète | [relaypartner.didavie.com/fr/developers](https://relaypartner.didavie.com/fr/developers) |

## Démarrage rapide

1. Créez un compte gratuit sur [relaysandbox.didavie.com](https://relaysandbox.didavie.com) et une clé boutique (`rb_sbx_...`). Guide : [docs/sandbox.fr.md](docs/sandbox.fr.md).
2. Appelez l'API :

```bash
export RELAY_API_KEY=rb_sbx_xxxxxxxxxxxx
BASE=https://relaysandbox.didavie.com/api/v1

curl -s "$BASE/me" -H "Authorization: Bearer $RELAY_API_KEY"

curl -s -G "$BASE/pricing/estimate" -H "Authorization: Bearer $RELAY_API_KEY" \
  --data-urlencode "delivery_address=Haie Vive, Cotonou"
```

3. Créez la livraison avec `POST /packages` (le `quote_id` de l'estimation garde le prix affiché), puis suivez-la avec `GET /packages/{tracking_code}` ou les webhooks.

Scripts complets : [`examples/curl/shop.sh`](examples/curl/shop.sh) (clé boutique) et [`examples/curl/agency.sh`](examples/curl/agency.sh) (clé agence).

## Clés

| Clé | Pour qui | Préfixe | Où la créer |
| --- | --- | --- | --- |
| Boutique | Une boutique approuvée sur Relay | `rb_live_` | Relay Partenaires > Boutique > Connecter mon site |
| Agence | Une agence de livraison | `relay_pk_live_` | Tableau de bord agence > Développeurs |
| Sandbox | Tout le monde, sans compte Relay | `rb_sbx_`, `relay_pk_sbx_` | [relaysandbox.didavie.com](https://relaysandbox.didavie.com) |

Les clés réelles utilisent l'URL de production. Pour tester, utilisez une clé sandbox. Les clés sandbox ne marchent que sur la sandbox. Gardez les clés sur votre serveur, jamais dans du code navigateur ou une application mobile.

## Contenu du dépôt

- [`openapi/openapi.json`](openapi/openapi.json) : description OpenAPI 3.0 de toutes les routes et des webhooks.
- [`docs/`](docs) : authentification, parcours boutique, sandbox, webhooks, codes d'erreur, limites (en anglais ; la sandbox aussi [en français](docs/sandbox.fr.md)).
- [`webhooks/`](webhooks) : vérification de la signature `X-Relay-Signature` en Node.js, PHP et Python, avec tests.
- [`collections/postman`](collections/postman) : collection Postman (importable dans Bruno et Insomnia).

## Assistance

- E-mail : relay@didavie.com
- Problèmes de documentation : [GitHub issues](https://github.com/didavie/relay-api/issues)
- Failles de sécurité : voir [SECURITY.md](SECURITY.md)

## Licence

Exemples, vérificateurs, collection et documentation sous [licence MIT](LICENSE). Relay et l'API Relay sont des services de Didavie ; leur utilisation est soumise aux conditions de Relay.

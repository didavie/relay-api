# Tester avec la sandbox

La sandbox [relaysandbox.didavie.com](https://relaysandbox.didavie.com) est une copie gratuite de l'API Relay avec des livraisons fictives. Aucun compte Relay n'est nécessaire.

[English version](sandbox.md)

## Obtenir une clé

1. Créez un compte sur [relaysandbox.didavie.com](https://relaysandbox.didavie.com) et confirmez votre adresse e-mail.
2. Ouvrez **Clés API** et créez une clé :
   - **Boutique** (`rb_sbx_...`) : sites web, WooCommerce, n8n et autres outils sans code.
   - **Agence** (`relay_pk_sbx_...`) : intégrations d'agence (création avec `client_address` et `delivery_address`, livreurs, zones).
3. Copiez la clé : elle n'est affichée qu'une fois.

## L'appeler

URL de base : `https://relaysandbox.didavie.com/api/v1`. Mêmes chemins, champs, codes d'erreur et webhooks signés qu'en production.

```bash
curl -s https://relaysandbox.didavie.com/api/v1/me -H "Authorization: Bearer rb_sbx_xxxxxxxxxxxx"
```

| Outil | Où mettre la clé sandbox |
| --- | --- |
| Votre code, curl | `Authorization: Bearer rb_sbx_...`, URL de base `https://relaysandbox.didavie.com/api/v1` |
| [Extension WooCommerce](https://github.com/didavie/relay-woocommerce) | WooCommerce > Réglages > Livraison > Relay > Clé API. Gardez l'adresse de l'API par défaut. |
| [Nœuds n8n](https://github.com/didavie/n8n-nodes-relay) | Identifiant Relay API > API Key, environnement *Automatic* |

Les extensions reconnaissent les préfixes `rb_sbx_` et `relay_pk_sbx_` et appellent la sandbox d'elles-mêmes.

## Avancement des livraisons

- **Avance automatique** (active par défaut) : livreur assigné tout de suite, colis récupéré après environ 2 minutes, livré après environ 5 minutes. Chaque étape envoie le webhook que la production enverrait.
- **Simulateur** : forcez un statut depuis la page **Livraisons**, ou par l'API avec `POST /sandbox/packages/{tracking_code}/simulate` et `{"status": "delivered"}`. `{"auto_advance": false}` met l'avance automatique en pause.

## Webhooks

Sur la page **Webhook**, saisissez votre URL https et copiez le secret de signature. Pas encore de serveur ? Utilisez l'URL de boîte de réception fournie : la sandbox garde les 20 derniers webhooks reçus et vérifie leur signature.

## Différences avec la production

- Prix calculés par une formule fixe de sandbox.
- Pas de vrais livreurs, zones ni affectation.
- Limites : 60 requêtes par minute et par clé, 50 livraisons par jour, 30 ouvertes en même temps.
- Comptes et données supprimés après 30 jours.
- Les clés sandbox sont refusées par la production, et l'inverse.

## Passer en production

Faites approuver votre boutique sur Relay, créez une clé réelle (`rb_live_...`) dans Relay Partenaires > Boutique > Connecter mon site, remplacez la clé sandbox, puis configurez l'URL de webhook de production et son nouveau secret.

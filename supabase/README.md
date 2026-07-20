# Backend Supabase Constat+

Les migrations de ce dossier mettent en place les profils professionnels, la
structure préparatoire des organisations, le catalogue commercial et les
lectures d'abonnement/quotas.

## Application locale

Appliquer les migrations avec la CLI Supabase liée au projet :

```text
supabase db push
```

Ne jamais placer de clé `service_role`, de secret fournisseur ou de clé OpenAI
dans Flutter ou dans ce dépôt.

Le client Flutter utilise uniquement :

- `SUPABASE_URL` ;
- `SUPABASE_PUBLISHABLE_KEY` ;
- `AUTH_REDIRECT_URL`.

Les rôles `controller` et `admin` doivent être attribués par une opération
administrative côté serveur. Le trigger d'inscription ignore volontairement
toute valeur de rôle fournie dans `user_metadata`.

## Catalogue initial

- mission à l'unité : 69 EUR, 5 analyses IA ;
- Solo : 99 EUR/mois, 5 missions, 50 analyses IA ;
- Pro : 198 EUR/mois, 10 missions, 150 analyses IA.

Les quotas IA sont lus depuis `subscription_plans`. Ils peuvent être modifiés
en base sans mise à jour de l'application. Les valeurs doivent être validées
avant l'ouverture commerciale.

Les tables `user_subscriptions`, `usage_periods` et `one_time_purchases` sont
en lecture seule pour Flutter. Leur écriture sera réservée aux fonctions
backend sécurisées des lots suivants.

## Mode Découverte

La migration `202607200009_discovery_mode.sql` configure le parcours gratuit
sans export exploitable. Les valeurs initiales sont stockées dans
`commercial_policies` : une mission active, trois pièces entièrement décrites,
cinq analyses IA, aperçu filigrané autorisé, exports Word et PDF définitif
interdits. Le cache local chiffré expire après 24 heures au maximum.

Ces valeurs sont des données métier et peuvent être modifiées en base. Chaque
modification doit incrémenter `revision`. Le champ de durée optionnelle reste
désactivé (`NULL`). Aucun accès temporaire n’est créé automatiquement.

Avant la pièce suivante, Flutter ouvre les offres `mission_unit`, `solo` et
`pro`. Le wizard reste sous la route de paiement : le retour après validation
serveur reprend donc le même brouillon en mémoire, sans recréer les contrôleurs
ni les photos sélectionnées. Le RPC `register_discovery_mission` applique aussi
la limite de mission côté serveur et `consume_ai_analysis` journalise le quota
Découverte de manière idempotente.
# Déploiement commercial

Les migrations sont conçues pour être appliquées dans l’ordre de leur nom :

```powershell
supabase db push
```

Le client Flutter ne contient aucune clé OpenAI. Configurez le secret uniquement
dans Supabase, puis déployez la fonction authentifiée :

```powershell
supabase secrets set OPENAI_API_KEY=sk-...
supabase secrets set OPENAI_VISION_MODEL=gpt-4.1-mini
supabase functions deploy analyze-room-photos
```

`SUPABASE_URL` et `SUPABASE_ANON_KEY` sont fournis automatiquement aux Edge
Functions hébergées. Les fonctions SQL de consommation sont les seules voies
d’écriture pour les droits, les quotas et l’association d’un achat unitaire.

## Google Play Billing — Android

La migration `202607200007_google_play_billing.sql` enregistre les identifiants
initiaux suivants. Ils doivent exister à l’identique dans Google Play Console :

- `constat_plus_mission_unit` : produit intégré consommable ;
- `constat_plus_solo_monthly` : abonnement avec offre de base mensuelle ;
- `constat_plus_pro_monthly` : abonnement avec offre de base mensuelle.

Avant le déploiement, définir l’identifiant Android définitif à la place de
`com.example.flutter_app` dans `android/app/build.gradle.kts`, créer une clé de
signature de production et publier au moins une version dans un canal de test
interne Google Play.

Créer ensuite un compte de service Google Cloud disposant uniquement des droits
Google Play Android Developer nécessaires à la consultation et à la validation
des commandes. Stocker son JSON exclusivement dans les secrets Supabase :

```powershell
supabase secrets set GOOGLE_PLAY_PACKAGE_NAME=com.votreentreprise.constatplus
supabase secrets set GOOGLE_PLAY_SERVICE_ACCOUNT_JSON='<json-du-compte-de-service>'
supabase secrets set GOOGLE_PLAY_RTDN_TOKEN='<secret-long-et-aleatoire>'
supabase functions deploy google-play-verify
supabase functions deploy google-play-rtdn --no-verify-jwt
```

La fonction `google-play-verify` exige le JWT Supabase de l’utilisateur. La
fonction `google-play-rtdn` est appelée par une souscription push Google Cloud
Pub/Sub et exige le secret `GOOGLE_PLAY_RTDN_TOKEN` dans l’en-tête
`x-constatplus-rtdn-token` ou dans le paramètre `token` de l’URL.

Dans Google Play Console, activer les notifications développeur en temps réel,
autoriser `google-play-developer-notifications@system.gserviceaccount.com` à
publier sur le topic Pub/Sub, puis créer la souscription push vers :

```text
https://<project-ref>.supabase.co/functions/v1/google-play-rtdn?token=<secret>
```

Configurer enfin les testeurs de licence et vérifier au minimum : achat réussi,
paiement lent `pending`, annulation, renouvellement, période de grâce,
restauration et remboursement. Un achat local ne donne jamais de droits avant
la réponse de l’API Google Play et l’écriture serveur idempotente.

## Stripe Billing — Windows

La migration `202607200008_stripe_windows_billing.sql` ajoute les clients
Stripe, les sessions Checkout et les documents de facturation. Elle installe
trois prix désactivés contenant `REPLACE_WITH_STRIPE_PRICE_*`. Dans Stripe,
créer les prix réels en mode test puis en mode production, remplacer ces trois
valeurs par les identifiants `price_...` correspondants et activer uniquement
les lignes de l’environnement utilisé.

Les clés secrètes, les URLs de retour et le secret de signature restent dans
Supabase :

```powershell
supabase secrets set STRIPE_SECRET_KEY=sk_test_...
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
supabase secrets set STRIPE_CHECKOUT_SUCCESS_URL=https://votre-domaine.example/paiement-confirme
supabase secrets set STRIPE_CHECKOUT_CANCEL_URL=https://votre-domaine.example/paiement-annule
supabase secrets set STRIPE_PORTAL_RETURN_URL=https://votre-domaine.example/retour-portail
supabase functions deploy stripe-checkout
supabase functions deploy stripe-customer-tools
supabase functions deploy stripe-webhook --no-verify-jwt
```

La page de succès doit inviter l’utilisateur à revenir dans Constat+ ;
l’application Windows reste ouverte et interroge uniquement l’état enregistré
par le webhook. La redirection navigateur ne donne donc jamais de droits à elle
seule.

Configurer le portail client Stripe dans le Dashboard, puis ajouter un endpoint
webhook vers :

```text
https://<project-ref>.supabase.co/functions/v1/stripe-webhook
```

Événements à sélectionner :

- `checkout.session.completed` ;
- `customer.subscription.created` ;
- `customer.subscription.updated` ;
- `customer.subscription.deleted` ;
- `invoice.paid` ;
- `invoice.payment_failed` ;
- `invoice.finalized`.

Tester en mode test Stripe au minimum : abonnement réussi, achat unitaire,
annulation de Checkout, renouvellement, paiement refusé, résiliation via le
portail, webhook rejoué et consultation d’une facture. Refaire ensuite toute la
configuration avec des produits, prix, secrets et endpoint webhook de
production distincts.

## Apple In-App Purchase — iPhone et iPad

La migration `202607200010_apple_billing.sql` prépare trois produits Apple,
désactivés tant que leur configuration App Store Connect n’est pas terminée :

- `constat_plus_mission_unit` : achat consommable ;
- `constat_plus_solo_monthly` : abonnement auto-renouvelable mensuel ;
- `constat_plus_pro_monthly` : abonnement auto-renouvelable mensuel.

Créer les deux abonnements dans le même groupe d’abonnements. Définir ensuite
le Bundle ID définitif dans Xcode, signer l’application avec l’équipe Apple,
ajouter la capacité In-App Purchase et compléter les prix, localisations et
informations de revue dans App Store Connect. Une fois les produits disponibles
en Sandbox, passer leurs lignes `provider_products` à `active = true`.

Dans App Store Connect, créer une clé In-App Purchase sous « Utilisateurs et
accès > Intégrations ». Télécharger également les certificats racine DER depuis
[Apple PKI](https://www.apple.com/certificateauthority/), les encoder séparément
en Base64 et fournir un tableau JSON. Les secrets restent exclusivement dans
Supabase :

```powershell
supabase secrets set APPLE_IAP_PRIVATE_KEY='<contenu-p8>'
supabase secrets set APPLE_IAP_KEY_ID='<key-id>'
supabase secrets set APPLE_IAP_ISSUER_ID='<issuer-id>'
supabase secrets set APPLE_BUNDLE_ID=com.votreentreprise.constatplus
supabase secrets set APPLE_APP_ID='<identifiant-numerique-app>'
supabase secrets set APPLE_ROOT_CERTIFICATES_BASE64='["<racine-1>","<racine-2>"]'
supabase functions deploy apple-verify
supabase functions deploy apple-notifications --no-verify-jwt
```

Configurer les App Store Server Notifications V2 de production et Sandbox vers :

```text
https://<project-ref>.supabase.co/functions/v1/apple-notifications
```

`apple-verify` relit la transaction auprès de l’App Store Server API, vérifie le
JWS avec la bibliothèque serveur officielle d’Apple et exige que
`appAccountToken` corresponde au compte Supabase. `apple-notifications` vérifie
également le `signedPayload` V2 et déduplique chaque `notificationUUID`. Le
téléphone ne peut donc jamais activer lui-même un droit.

Tester avec StoreKit Sandbox et TestFlight : achat consommable, achat Solo et
Pro, annulation, Ask to Buy, restauration, renouvellement accéléré, échec de
renouvellement, période de grâce, expiration, remboursement et rejeu d’une
notification. Les consommables ne sont pas restaurés par StoreKit ; leur droit
reste néanmoins conservé dans le registre serveur Constat+.

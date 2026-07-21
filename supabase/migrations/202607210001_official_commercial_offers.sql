alter table public.subscription_plans
  add column if not exists tax_display text not null default 'htva',
  add column if not exists additional_mission_price_minor integer,
  add column if not exists feature_labels text[] not null default '{}';

alter table public.subscription_plans
  drop constraint if exists subscription_plans_tax_display_known;

alter table public.subscription_plans
  add constraint subscription_plans_tax_display_known
  check (tax_display in ('htva', 'tvac'));

alter table public.subscription_plans
  drop constraint if exists subscription_plans_additional_mission_price_positive;

alter table public.subscription_plans
  add constraint subscription_plans_additional_mission_price_positive
  check (
    additional_mission_price_minor is null
    or additional_mission_price_minor >= 0
  );

update public.subscription_plans
set
  name = 'Mission unique',
  description = 'Une mission pour un seul état des lieux, sans abonnement.',
  price_minor = 6900,
  currency = 'EUR',
  mission_quota = 1,
  ai_analysis_quota = 5,
  tax_display = 'tvac',
  additional_mission_price_minor = null,
  feature_labels = array[
    'Utilisable pour un seul état des lieux',
    '5 analyses IA',
    'Pas d’abonnement'
  ]
where code = 'mission_unit';

update public.subscription_plans
set
  name = 'Solo',
  description = 'Pour un expert indépendant réalisant jusqu’à 5 états des lieux par mois.',
  price_minor = 9900,
  currency = 'EUR',
  mission_quota = 5,
  ai_analysis_quota = 50,
  tax_display = 'htva',
  additional_mission_price_minor = 2000,
  feature_labels = array[
    'Jusqu’à 5 états des lieux par mois',
    '50 analyses IA par mois',
    'Rapports PDF et Word',
    'Signature électronique',
    'Sauvegarde cloud'
  ]
where code = 'solo';

update public.subscription_plans
set
  name = 'Pro',
  description = 'Pour les équipes réalisant jusqu’à 10 états des lieux par mois.',
  price_minor = 19800,
  currency = 'EUR',
  mission_quota = 10,
  ai_analysis_quota = 150,
  tax_display = 'htva',
  additional_mission_price_minor = 1500,
  feature_labels = array[
    'Jusqu’à 10 états des lieux par mois',
    '150 analyses IA par mois',
    'Toutes les fonctionnalités Solo',
    'Gestion d’équipe',
    'Tableau de bord entreprise',
    'Contrôle interne',
    'Affectation des experts',
    'Historique complet',
    'Communication interne par dossier'
  ]
where code = 'pro';

comment on column public.subscription_plans.tax_display is
  'Mention fiscale commerciale affichée avec le prix : HTVA ou TVAC.';

comment on column public.subscription_plans.additional_mission_price_minor is
  'Prix HTVA configurable d’un état des lieux supplémentaire, en unité monétaire mineure.';

comment on column public.subscription_plans.feature_labels is
  'Avantages commerciaux configurables affichés dans les offres.';

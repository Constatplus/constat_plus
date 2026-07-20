create type public.billing_period as enum ('none', 'monthly');
create type public.payment_provider as enum (
  'google_play',
  'stripe',
  'apple',
  'demo'
);
create type public.subscription_status as enum (
  'pending',
  'active',
  'grace_period',
  'past_due',
  'suspended',
  'canceled',
  'expired',
  'incomplete',
  'failed'
);
create type public.purchase_status as enum (
  'pending',
  'verified',
  'assigned',
  'refunded',
  'canceled',
  'failed'
);

create table public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text not null default '',
  billing_period public.billing_period not null,
  price_minor bigint not null,
  currency char(3) not null default 'EUR',
  mission_quota integer not null,
  ai_analysis_quota integer not null,
  maximum_users integer not null default 1,
  platform_availability text[] not null
    default array['android', 'windows', 'ios'],
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint subscription_plans_code_not_blank check (length(trim(code)) > 0),
  constraint subscription_plans_price_positive check (price_minor >= 0),
  constraint subscription_plans_mission_quota_positive
    check (mission_quota >= 0),
  constraint subscription_plans_ai_quota_positive
    check (ai_analysis_quota >= 0),
  constraint subscription_plans_maximum_users_positive
    check (maximum_users >= 1),
  constraint subscription_plans_platforms_known check (
    platform_availability <@ array['android', 'windows', 'ios']::text[]
  )
);

create table public.provider_products (
  id uuid primary key default gen_random_uuid(),
  plan_code text not null
    references public.subscription_plans (code) on update cascade on delete restrict,
  provider public.payment_provider not null,
  provider_product_id text not null,
  platform text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_product_id),
  unique (plan_code, provider, platform),
  constraint provider_products_platform_known
    check (platform in ('android', 'windows', 'ios')),
  constraint provider_products_id_not_blank
    check (length(trim(provider_product_id)) > 0)
);

create table public.user_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete restrict,
  organization_id uuid references public.organizations (id) on delete restrict,
  plan_code text not null
    references public.subscription_plans (code) on update cascade on delete restrict,
  provider public.payment_provider not null,
  provider_customer_id text,
  provider_subscription_id text not null,
  provider_product_id text not null,
  provider_purchase_token text,
  status public.subscription_status not null default 'pending',
  started_at timestamptz not null,
  current_period_start timestamptz not null,
  current_period_end timestamptz not null,
  cancel_at_period_end boolean not null default false,
  canceled_at timestamptz,
  grace_period_end timestamptz,
  last_verified_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_subscription_id),
  constraint user_subscriptions_period_valid
    check (current_period_end > current_period_start)
);

create index user_subscriptions_user_id_idx
  on public.user_subscriptions (user_id, created_at desc);
create index user_subscriptions_organization_id_idx
  on public.user_subscriptions (organization_id, created_at desc)
  where organization_id is not null;

create table public.usage_periods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id) on delete restrict,
  organization_id uuid references public.organizations (id) on delete restrict,
  subscription_id uuid not null
    references public.user_subscriptions (id) on delete cascade,
  period_start timestamptz not null,
  period_end timestamptz not null,
  missions_used integer not null default 0,
  ai_analyses_used integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint usage_periods_owner_xor check (
    (user_id is not null and organization_id is null)
    or (user_id is null and organization_id is not null)
  ),
  constraint usage_periods_period_valid check (period_end > period_start),
  constraint usage_periods_missions_positive check (missions_used >= 0),
  constraint usage_periods_ai_positive check (ai_analyses_used >= 0),
  unique (subscription_id, period_start, period_end)
);

create index usage_periods_user_id_idx
  on public.usage_periods (user_id, period_end desc)
  where user_id is not null;
create index usage_periods_organization_id_idx
  on public.usage_periods (organization_id, period_end desc)
  where organization_id is not null;

create table public.one_time_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete restrict,
  mission_id uuid,
  provider public.payment_provider not null,
  provider_transaction_id text not null,
  provider_product_id text not null,
  amount_minor bigint not null,
  currency char(3) not null default 'EUR',
  status public.purchase_status not null default 'pending',
  purchased_at timestamptz not null,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_transaction_id),
  constraint one_time_purchases_amount_positive check (amount_minor >= 0)
);

create index one_time_purchases_user_id_idx
  on public.one_time_purchases (user_id, purchased_at desc);
create unique index one_time_purchases_mission_unique
  on public.one_time_purchases (mission_id)
  where mission_id is not null and status = 'assigned';

create trigger subscription_plans_set_updated_at
before update on public.subscription_plans
for each row execute function public.set_updated_at();

create trigger provider_products_set_updated_at
before update on public.provider_products
for each row execute function public.set_updated_at();

create trigger user_subscriptions_set_updated_at
before update on public.user_subscriptions
for each row execute function public.set_updated_at();

create trigger usage_periods_set_updated_at
before update on public.usage_periods
for each row execute function public.set_updated_at();

create trigger one_time_purchases_set_updated_at
before update on public.one_time_purchases
for each row execute function public.set_updated_at();

insert into public.subscription_plans (
  code,
  name,
  description,
  billing_period,
  price_minor,
  currency,
  mission_quota,
  ai_analysis_quota,
  maximum_users,
  platform_availability,
  active,
  sort_order
)
values
  (
    'mission_unit',
    'Mission à l’unité',
    'Une mission payante et son rapport définitif, sans abonnement.',
    'none',
    6900,
    'EUR',
    1,
    5,
    1,
    array['android', 'windows', 'ios'],
    true,
    10
  ),
  (
    'solo',
    'Solo',
    'Pour un professionnel indépendant avec un volume régulier.',
    'monthly',
    9900,
    'EUR',
    5,
    50,
    1,
    array['android', 'windows', 'ios'],
    true,
    20
  ),
  (
    'pro',
    'Pro',
    'Pour une activité soutenue et la collaboration future.',
    'monthly',
    19800,
    'EUR',
    10,
    150,
    5,
    array['android', 'windows', 'ios'],
    true,
    30
  )
on conflict (code) do update
set
  name = excluded.name,
  description = excluded.description,
  billing_period = excluded.billing_period,
  price_minor = excluded.price_minor,
  currency = excluded.currency,
  mission_quota = excluded.mission_quota,
  ai_analysis_quota = excluded.ai_analysis_quota,
  maximum_users = excluded.maximum_users,
  platform_availability = excluded.platform_availability,
  active = excluded.active,
  sort_order = excluded.sort_order;

comment on column public.subscription_plans.ai_analysis_quota is
  'Valeur configurable en base. Valeurs initiales : mission 5, Solo 50, Pro 150.';

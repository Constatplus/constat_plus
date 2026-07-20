alter table public.subscription_plans enable row level security;
alter table public.provider_products enable row level security;
alter table public.user_subscriptions enable row level security;
alter table public.usage_periods enable row level security;
alter table public.one_time_purchases enable row level security;

create policy subscription_plans_read_active
on public.subscription_plans
for select
to anon, authenticated
using (active);

create policy provider_products_read_active
on public.provider_products
for select
to authenticated
using (active);

create policy user_subscriptions_read_owner
on public.user_subscriptions
for select
to authenticated
using (
  user_id = auth.uid()
  or (
    organization_id is not null
    and public.is_organization_member(organization_id, auth.uid())
  )
  or public.is_app_admin(auth.uid())
);

create policy usage_periods_read_owner
on public.usage_periods
for select
to authenticated
using (
  user_id = auth.uid()
  or (
    organization_id is not null
    and public.is_organization_member(organization_id, auth.uid())
  )
  or public.is_app_admin(auth.uid())
);

create policy one_time_purchases_read_owner
on public.one_time_purchases
for select
to authenticated
using (user_id = auth.uid() or public.is_app_admin(auth.uid()));

revoke all on public.subscription_plans from anon, authenticated;
grant select on public.subscription_plans to anon, authenticated;

revoke all on public.provider_products from anon, authenticated;
grant select on public.provider_products to authenticated;

revoke all on public.user_subscriptions from anon, authenticated;
grant select on public.user_subscriptions to authenticated;

revoke all on public.usage_periods from anon, authenticated;
grant select on public.usage_periods to authenticated;

revoke all on public.one_time_purchases from anon, authenticated;
grant select on public.one_time_purchases to authenticated;

comment on table public.user_subscriptions is
  'Écriture exclusivement côté serveur après vérification fournisseur.';
comment on table public.usage_periods is
  'Écriture exclusivement via fonctions atomiques du backend.';
comment on table public.one_time_purchases is
  'Aucun achat envoyé par Flutter ne constitue une preuve de paiement.';

alter table public.commercial_missions enable row level security;
alter table public.mission_entitlements enable row level security;
alter table public.usage_events enable row level security;
alter table public.payment_events enable row level security;

create policy commercial_missions_read_owner
on public.commercial_missions for select to authenticated
using (
  owner_user_id = auth.uid()
  or (
    organization_id is not null
    and public.is_organization_member(organization_id, auth.uid())
  )
  or public.is_app_admin(auth.uid())
);

create policy mission_entitlements_read_owner
on public.mission_entitlements for select to authenticated
using (user_id = auth.uid() or public.is_app_admin(auth.uid()));

create policy usage_events_read_owner
on public.usage_events for select to authenticated
using (
  user_id = auth.uid()
  or (
    organization_id is not null
    and public.is_organization_member(organization_id, auth.uid())
  )
  or public.is_app_admin(auth.uid())
);

revoke all on public.commercial_missions from anon, authenticated;
revoke all on public.mission_entitlements from anon, authenticated;
revoke all on public.usage_events from anon, authenticated;
revoke all on public.payment_events from anon, authenticated;

grant select on public.commercial_missions to authenticated;
grant select on public.mission_entitlements to authenticated;
grant select on public.usage_events to authenticated;

comment on table public.commercial_missions is
  'Les écritures passent exclusivement par les fonctions atomiques de droits.';
comment on table public.usage_events is
  'Journal append-only idempotent des consommations de quota.';

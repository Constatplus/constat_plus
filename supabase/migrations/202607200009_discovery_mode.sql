alter table public.profiles
  add column vat_number text not null default '';

create table public.commercial_policies (
  id boolean primary key default true check (id),
  revision integer not null default 1 check (revision > 0),
  discovery_enabled boolean not null default true,
  discovery_max_active_missions integer not null
    check (discovery_max_active_missions >= 0),
  discovery_max_fully_described_rooms integer not null
    check (discovery_max_fully_described_rooms >= 0),
  discovery_ai_analysis_quota integer not null
    check (discovery_ai_analysis_quota >= 0),
  discovery_cache_ttl_hours integer not null
    check (discovery_cache_ttl_hours between 1 and 24),
  discovery_optional_duration_days integer
    check (
      discovery_optional_duration_days is null
      or discovery_optional_duration_days > 0
    ),
  discovery_preview_enabled boolean not null default true,
  discovery_word_export_enabled boolean not null default false,
  discovery_final_pdf_export_enabled boolean not null default false,
  updated_at timestamptz not null default now()
);

insert into public.commercial_policies (
  id,
  revision,
  discovery_max_active_missions,
  discovery_max_fully_described_rooms,
  discovery_ai_analysis_quota,
  discovery_cache_ttl_hours,
  discovery_optional_duration_days
)
values (true, 1, 1, 3, 5, 24, null)
on conflict (id) do nothing;

create trigger commercial_policies_set_updated_at
before update on public.commercial_policies
for each row execute function public.set_updated_at();

create table public.discovery_ai_usage (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  analyses_used integer not null default 0 check (analyses_used >= 0),
  updated_at timestamptz not null default now()
);

create table public.discovery_ai_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  mission_id uuid not null
    references public.commercial_missions (id) on delete cascade,
  idempotency_key text not null,
  created_at timestamptz not null default now(),
  unique (user_id, idempotency_key)
);

create trigger discovery_ai_usage_set_updated_at
before update on public.discovery_ai_usage
for each row execute function public.set_updated_at();

create table public.billing_issuer (
  id boolean primary key default true check (id),
  legal_name text not null,
  address_line text not null,
  postal_code text not null,
  city text not null,
  country_code char(2) not null,
  company_number text not null,
  updated_at timestamptz not null default now()
);

insert into public.billing_issuer (
  id, legal_name, address_line, postal_code, city, country_code, company_number
)
values (
  true,
  'Gaudium Immo SRL',
  '19 Avenue du Pont Rouge',
  '7000',
  'Mons',
  'BE',
  'BE 0786.702.365'
)
on conflict (id) do update
set legal_name = excluded.legal_name,
    address_line = excluded.address_line,
    postal_code = excluded.postal_code,
    city = excluded.city,
    country_code = excluded.country_code,
    company_number = excluded.company_number;

create trigger billing_issuer_set_updated_at
before update on public.billing_issuer
for each row execute function public.set_updated_at();

update public.subscription_plans
set ai_analysis_quota = case code
  when 'mission_unit' then 5
  when 'solo' then 50
  when 'pro' then 150
  else ai_analysis_quota
end
where code in ('mission_unit', 'solo', 'pro');

comment on column public.subscription_plans.ai_analysis_quota is
  'Quota configurable en base. Valeurs initiales : mission 5, Solo 50, Pro 150.';

create or replace function public.close_previous_active_subscription()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status = 'active'::public.subscription_status then
    update public.user_subscriptions
    set status = 'canceled',
        canceled_at = coalesce(canceled_at, now()),
        last_verified_at = now()
    where user_id = new.user_id
      and id <> new.id
      and status = 'active'::public.subscription_status;
  end if;
  return new;
end;
$$;

create trigger user_subscriptions_close_previous_active
before insert or update of status on public.user_subscriptions
for each row execute function public.close_previous_active_subscription();

create unique index user_subscriptions_one_live_per_user
on public.user_subscriptions (user_id)
where status in (
  'active'
);

create or replace function public.get_discovery_access_state()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_policy public.commercial_policies%rowtype;
  v_now timestamptz := now();
  v_has_paid_access boolean;
  v_ai_used integer := 0;
  v_active_missions jsonb;
  v_paid_missions jsonb;
begin
  if v_uid is null then raise exception 'not_authenticated'; end if;
  select * into strict v_policy from public.commercial_policies where id;

  select (
    exists (
      select 1 from public.user_subscriptions subscription
      where subscription.user_id = v_uid
        and subscription.status = 'active'
        and subscription.current_period_start <= v_now
        and subscription.current_period_end > v_now
    )
  ) into v_has_paid_access;

  select coalesce(jsonb_agg(mission.id), '[]'::jsonb)
  into v_active_missions
  from public.commercial_missions mission
  where mission.owner_user_id = v_uid and mission.status = 'draft';

  select coalesce(jsonb_agg(entitlement.mission_id), '[]'::jsonb)
  into v_paid_missions
  from (
    select entitlement.mission_id
    from public.mission_entitlements entitlement
    where entitlement.user_id = v_uid
    union
    select purchase.mission_id
    from public.one_time_purchases purchase
    where purchase.user_id = v_uid
      and purchase.status = 'verified'
      and purchase.mission_id is not null
  ) entitlement;

  select coalesce(analyses_used, 0) into v_ai_used
  from public.discovery_ai_usage where user_id = v_uid;

  return jsonb_build_object(
    'user_id', v_uid,
    'policy', jsonb_build_object(
      'revision', v_policy.revision,
      'max_active_missions', v_policy.discovery_max_active_missions,
      'max_fully_described_rooms',
        v_policy.discovery_max_fully_described_rooms,
      'ai_analysis_quota', v_policy.discovery_ai_analysis_quota,
      'cache_ttl_hours', v_policy.discovery_cache_ttl_hours,
      'optional_duration_days', v_policy.discovery_optional_duration_days,
      'preview_enabled', v_policy.discovery_preview_enabled,
      'word_export_enabled', v_policy.discovery_word_export_enabled,
      'final_pdf_export_enabled',
        v_policy.discovery_final_pdf_export_enabled
    ),
    'has_paid_access', v_has_paid_access,
    'active_mission_ids', v_active_missions,
    'paid_mission_ids', v_paid_missions,
    'ai_analyses_used', v_ai_used,
    'verified_at', v_now,
    'valid_until', v_now + make_interval(
      hours => least(v_policy.discovery_cache_ttl_hours, 24)
    )
  );
end;
$$;

create or replace function public.register_discovery_mission(
  p_mission_id uuid,
  p_mission_type text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_policy public.commercial_policies%rowtype;
  v_existing_owner uuid;
  v_has_paid_access boolean;
  v_has_unassigned_purchase boolean;
  v_active_count integer;
begin
  if v_uid is null then raise exception 'not_authenticated'; end if;
  if p_mission_type not in ('entry', 'exit', 'before_works', 'after_works') then
    raise exception 'unknown_mission_type';
  end if;
  select owner_user_id into v_existing_owner
  from public.commercial_missions where id = p_mission_id;
  if found then
    if v_existing_owner <> v_uid then raise exception 'mission_not_owned'; end if;
    return jsonb_build_object('allowed', true, 'existing', true);
  end if;

  select * into strict v_policy from public.commercial_policies where id;
  select (
    exists (
      select 1 from public.user_subscriptions subscription
      where subscription.user_id = v_uid
        and subscription.status = 'active'
        and subscription.current_period_start <= now()
        and subscription.current_period_end > now()
    )
  ) into v_has_paid_access;
  select exists (
    select 1 from public.one_time_purchases purchase
    where purchase.user_id = v_uid
      and purchase.status = 'verified'
      and purchase.mission_id is null
  ) into v_has_unassigned_purchase;

  select count(*) into v_active_count
  from public.commercial_missions mission
  where mission.owner_user_id = v_uid and mission.status = 'draft';
  if not v_has_paid_access and not v_has_unassigned_purchase
     and v_active_count >= v_policy.discovery_max_active_missions then
    return jsonb_build_object(
      'allowed', false,
      'reason', 'discovery_mission_limit_reached'
    );
  end if;

  insert into public.commercial_missions (id, owner_user_id, mission_type)
  values (p_mission_id, v_uid, p_mission_type);
  if not v_has_paid_access and v_has_unassigned_purchase then
    update public.one_time_purchases
    set mission_id = p_mission_id
    where id = (
      select purchase.id from public.one_time_purchases purchase
      where purchase.user_id = v_uid
        and purchase.status = 'verified'
        and purchase.mission_id is null
      order by purchase.purchased_at
      limit 1 for update skip locked
    );
  end if;
  return jsonb_build_object('allowed', true, 'existing', false);
end;
$$;

create or replace function public.consume_ai_analysis(
  p_mission_id uuid,
  p_mission_type text,
  p_idempotency_key text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_status public.account_status;
  v_subscription public.user_subscriptions%rowtype;
  v_plan public.subscription_plans%rowtype;
  v_usage public.usage_periods%rowtype;
  v_policy public.commercial_policies%rowtype;
  v_discovery_used integer;
  v_registration jsonb;
begin
  if v_uid is null then
    return jsonb_build_object('allowed', false, 'reason', 'not_authenticated');
  end if;
  if nullif(trim(p_idempotency_key), '') is null then
    raise exception 'idempotency_key_required';
  end if;
  select account_status into v_status from public.profiles where id = v_uid;
  if v_status is distinct from 'active'::public.account_status then
    return jsonb_build_object('allowed', false, 'reason', 'account_inactive');
  end if;

  if exists (
    select 1 from public.usage_events
    where user_id = v_uid and idempotency_key = p_idempotency_key
      and mission_id = p_mission_id and usage_kind = 'ai_analysis'
  ) or exists (
    select 1 from public.discovery_ai_events
    where user_id = v_uid and idempotency_key = p_idempotency_key
      and mission_id = p_mission_id
  ) then
    return jsonb_build_object('allowed', true, 'already_consumed', true);
  end if;

  v_registration := public.register_discovery_mission(
    p_mission_id, p_mission_type
  );
  if not coalesce((v_registration ->> 'allowed')::boolean, false) then
    return v_registration;
  end if;
  perform 1 from public.commercial_missions
  where id = p_mission_id for update;

  select subscription.* into v_subscription
  from public.user_subscriptions subscription
  where subscription.user_id = v_uid
    and subscription.status = 'active'
    and subscription.current_period_start <= now()
    and subscription.current_period_end > now()
  order by subscription.current_period_end desc
  limit 1 for update;

  if found then
    select * into v_plan from public.subscription_plans
    where code = v_subscription.plan_code and active;
    select * into v_usage from public.usage_periods
    where subscription_id = v_subscription.id
      and period_start <= now() and period_end > now()
    order by period_end desc limit 1 for update;
    if not found then
      insert into public.usage_periods (
        user_id, subscription_id, period_start, period_end
      ) values (
        v_uid, v_subscription.id,
        v_subscription.current_period_start, v_subscription.current_period_end
      ) returning * into v_usage;
    end if;
    if v_usage.ai_analyses_used >= v_plan.ai_analysis_quota then
      return jsonb_build_object('allowed', false, 'reason', 'ai_quota_reached');
    end if;
    update public.usage_periods
    set ai_analyses_used = ai_analyses_used + 1 where id = v_usage.id;
    insert into public.usage_events (
      user_id, organization_id, subscription_id, mission_id,
      usage_kind, idempotency_key
    ) values (
      v_uid, v_subscription.organization_id, v_subscription.id,
      p_mission_id, 'ai_analysis', p_idempotency_key
    );
    return jsonb_build_object('allowed', true, 'already_consumed', false);
  end if;

  select * into strict v_policy from public.commercial_policies where id;
  insert into public.discovery_ai_usage (user_id)
  values (v_uid) on conflict (user_id) do nothing;
  select analyses_used into v_discovery_used
  from public.discovery_ai_usage where user_id = v_uid for update;
  if v_discovery_used >= v_policy.discovery_ai_analysis_quota then
    return jsonb_build_object('allowed', false, 'reason', 'ai_quota_reached');
  end if;
  update public.discovery_ai_usage
  set analyses_used = analyses_used + 1 where user_id = v_uid;
  insert into public.discovery_ai_events (
    user_id, mission_id, idempotency_key
  ) values (v_uid, p_mission_id, p_idempotency_key);
  return jsonb_build_object('allowed', true, 'already_consumed', false);
end;
$$;

create or replace function public.can_export_paid_report(p_mission_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then
    return jsonb_build_object('allowed', false, 'reason', 'not_authenticated');
  end if;
  if exists (
    select 1 from public.mission_entitlements entitlement
    where entitlement.user_id = v_uid
      and entitlement.mission_id = p_mission_id
  ) or exists (
    select 1 from public.user_subscriptions subscription
    where subscription.user_id = v_uid
      and subscription.status = 'active'
      and subscription.current_period_start <= now()
      and subscription.current_period_end > now()
  ) or exists (
    select 1 from public.one_time_purchases purchase
    where purchase.user_id = v_uid
      and purchase.status = 'verified'
      and purchase.mission_id = p_mission_id
  ) then
    return jsonb_build_object('allowed', true);
  end if;
  return jsonb_build_object(
    'allowed', false,
    'reason', 'mission_payment_required'
  );
end;
$$;

revoke all on public.commercial_policies from anon, authenticated;
revoke all on public.discovery_ai_usage from anon, authenticated;
revoke all on public.discovery_ai_events from anon, authenticated;
revoke all on public.billing_issuer from anon, authenticated;

revoke all on function public.get_discovery_access_state() from public;
revoke all on function public.register_discovery_mission(uuid, text) from public;
revoke all on function public.consume_ai_analysis(uuid, text, text) from public;
revoke all on function public.can_export_paid_report(uuid) from public;
revoke all on function public.close_previous_active_subscription() from public;
grant execute on function public.get_discovery_access_state() to authenticated;
grant execute on function public.register_discovery_mission(uuid, text)
  to authenticated;
grant execute on function public.consume_ai_analysis(uuid, text, text)
  to authenticated;
grant execute on function public.can_export_paid_report(uuid)
  to authenticated;

alter table public.commercial_policies enable row level security;
alter table public.discovery_ai_usage enable row level security;
alter table public.discovery_ai_events enable row level security;
alter table public.billing_issuer enable row level security;

comment on table public.commercial_policies is
  'Politique commerciale versionnée. Le mode découverte remplace tout essai.';
comment on table public.billing_issuer is
  'Coordonnées légales configurables de l’émetteur des factures.';

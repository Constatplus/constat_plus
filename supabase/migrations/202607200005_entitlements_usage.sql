create type public.commercial_mission_status as enum (
  'draft',
  'finalized',
  'archived'
);
create type public.entitlement_source as enum ('subscription', 'one_time');
create type public.usage_kind as enum ('mission', 'ai_analysis');

create table public.commercial_missions (
  id uuid primary key,
  owner_user_id uuid not null references public.profiles (id) on delete restrict,
  organization_id uuid references public.organizations (id) on delete restrict,
  mission_type text not null,
  status public.commercial_mission_status not null default 'draft',
  finalized_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint commercial_missions_type_known check (
    mission_type in ('entry', 'exit', 'before_works', 'after_works')
  )
);

create table public.mission_entitlements (
  mission_id uuid primary key
    references public.commercial_missions (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete restrict,
  source_kind public.entitlement_source not null,
  source_id uuid not null,
  includes_ai_analysis boolean not null default false,
  granted_at timestamptz not null default now()
);

create table public.usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete restrict,
  organization_id uuid references public.organizations (id) on delete restrict,
  subscription_id uuid not null
    references public.user_subscriptions (id) on delete restrict,
  mission_id uuid not null
    references public.commercial_missions (id) on delete restrict,
  usage_kind public.usage_kind not null,
  units integer not null default 1,
  idempotency_key text not null,
  created_at timestamptz not null default now(),
  constraint usage_events_units_positive check (units > 0),
  constraint usage_events_key_not_blank check (length(trim(idempotency_key)) > 0)
);

create table public.payment_events (
  id uuid primary key default gen_random_uuid(),
  provider public.payment_provider not null,
  provider_event_id text not null,
  event_type text not null,
  payload_hash text not null,
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  processing_error text,
  unique (provider, provider_event_id)
);

alter table public.one_time_purchases
  add constraint one_time_purchases_mission_fk
  foreign key (mission_id) references public.commercial_missions (id)
  on delete restrict;

create index commercial_missions_owner_idx
  on public.commercial_missions (owner_user_id, updated_at desc);
create index mission_entitlements_user_idx
  on public.mission_entitlements (user_id, granted_at desc);
create index usage_events_user_idx
  on public.usage_events (user_id, created_at desc);
create unique index usage_events_user_idempotency_unique
  on public.usage_events (user_id, idempotency_key);

create trigger commercial_missions_set_updated_at
before update on public.commercial_missions
for each row execute function public.set_updated_at();

create or replace function public.ensure_owned_mission(
  p_mission_id uuid,
  p_mission_type text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_owner uuid;
begin
  if p_mission_type not in ('entry', 'exit', 'before_works', 'after_works') then
    raise exception 'unknown_mission_type';
  end if;

  select owner_user_id into v_owner
  from public.commercial_missions
  where id = p_mission_id;

  if found and v_owner <> auth.uid() then
    raise exception 'mission_not_owned';
  end if;

  insert into public.commercial_missions (id, owner_user_id, mission_type)
  values (p_mission_id, auth.uid(), p_mission_type)
  on conflict (id) do update
  set mission_type = excluded.mission_type;
end;
$$;

create or replace function public.consume_mission_entitlement(
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
  v_purchase public.one_time_purchases%rowtype;
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

  perform public.ensure_owned_mission(p_mission_id, p_mission_type);
  perform 1 from public.commercial_missions
  where id = p_mission_id for update;

  if exists (
    select 1 from public.mission_entitlements where mission_id = p_mission_id
  ) then
    return jsonb_build_object(
      'allowed', true,
      'already_consumed', true,
      'mission_id', p_mission_id
    );
  end if;

  select subscription.* into v_subscription
  from public.user_subscriptions subscription
  where subscription.user_id = v_uid
    and subscription.status in (
      'active'::public.subscription_status
    )
    and subscription.current_period_start <= now()
    and subscription.current_period_end > now()
  order by subscription.current_period_end desc
  limit 1
  for update;

  if found then
    select * into v_plan
    from public.subscription_plans
    where code = v_subscription.plan_code and active;

    select * into v_usage
    from public.usage_periods
    where subscription_id = v_subscription.id
      and period_start <= now() and period_end > now()
    order by period_end desc
    limit 1
    for update;

    if not found then
      insert into public.usage_periods (
        user_id, subscription_id, period_start, period_end
      ) values (
        v_uid, v_subscription.id,
        v_subscription.current_period_start, v_subscription.current_period_end
      ) returning * into v_usage;
    end if;

    if v_usage.missions_used < v_plan.mission_quota then
      update public.usage_periods
      set missions_used = missions_used + 1
      where id = v_usage.id;
      insert into public.usage_events (
        user_id, organization_id, subscription_id, mission_id,
        usage_kind, idempotency_key
      ) values (
        v_uid, v_subscription.organization_id, v_subscription.id,
        p_mission_id, 'mission', p_idempotency_key
      );
      insert into public.mission_entitlements (
        mission_id, user_id, source_kind, source_id
      ) values (
        p_mission_id, v_uid, 'subscription', v_subscription.id
      );
      update public.commercial_missions
      set status = 'finalized', finalized_at = now()
      where id = p_mission_id;
      return jsonb_build_object('allowed', true, 'already_consumed', false);
    end if;
  end if;

  select * into v_purchase
  from public.one_time_purchases
  where user_id = v_uid and status = 'verified'
    and (mission_id is null or mission_id = p_mission_id)
  order by purchased_at
  limit 1
  for update skip locked;

  if found then
    update public.one_time_purchases
    set status = 'assigned', mission_id = p_mission_id
    where id = v_purchase.id;
    insert into public.mission_entitlements (
      mission_id, user_id, source_kind, source_id
    ) values (p_mission_id, v_uid, 'one_time', v_purchase.id);
    update public.commercial_missions
    set status = 'finalized', finalized_at = now()
    where id = p_mission_id;
    return jsonb_build_object('allowed', true, 'already_consumed', false);
  end if;

  return jsonb_build_object(
    'allowed', false,
    'reason', case when v_subscription.id is null
      then 'mission_payment_required' else 'mission_quota_reached' end
  );
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
begin
  if v_uid is null then
    return jsonb_build_object('allowed', false, 'reason', 'not_authenticated');
  end if;
  select account_status into v_status from public.profiles where id = v_uid;
  if v_status is distinct from 'active'::public.account_status then
    return jsonb_build_object('allowed', false, 'reason', 'account_inactive');
  end if;
  perform public.ensure_owned_mission(p_mission_id, p_mission_type);
  perform 1 from public.commercial_missions
  where id = p_mission_id for update;

  if exists (
    select 1 from public.usage_events
    where user_id = v_uid and idempotency_key = p_idempotency_key
      and mission_id = p_mission_id and usage_kind = 'ai_analysis'
  ) then
    return jsonb_build_object('allowed', true, 'already_consumed', true);
  end if;

  select subscription.* into v_subscription
  from public.user_subscriptions subscription
  where subscription.user_id = v_uid
    and subscription.status = 'active'
    and subscription.current_period_start <= now()
    and subscription.current_period_end > now()
  order by subscription.current_period_end desc
  limit 1
  for update;
  if not found then
    return jsonb_build_object('allowed', false, 'reason', 'subscription_required');
  end if;

  if exists (
    select 1 from public.usage_events
    where user_id = v_uid and idempotency_key = p_idempotency_key
      and mission_id = p_mission_id and usage_kind = 'ai_analysis'
  ) then
    return jsonb_build_object('allowed', true, 'already_consumed', true);
  end if;

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
end;
$$;

revoke all on function public.ensure_owned_mission(uuid, text) from public;
revoke all on function public.consume_mission_entitlement(uuid, text, text) from public;
revoke all on function public.consume_ai_analysis(uuid, text, text) from public;
grant execute on function public.consume_mission_entitlement(uuid, text, text)
  to authenticated;
grant execute on function public.consume_ai_analysis(uuid, text, text)
  to authenticated;

comment on table public.payment_events is
  'Journal idempotent alimenté uniquement par les webhooks fournisseurs.';

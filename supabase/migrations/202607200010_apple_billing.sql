insert into public.provider_products (
  plan_code,
  provider,
  provider_product_id,
  platform,
  active
)
values
  ('mission_unit', 'apple', 'constat_plus_mission_unit', 'ios', false),
  ('solo', 'apple', 'constat_plus_solo_monthly', 'ios', false),
  ('pro', 'apple', 'constat_plus_pro_monthly', 'ios', false)
on conflict (plan_code, provider, platform) do update
set
  provider_product_id = excluded.provider_product_id,
  active = excluded.active;

create or replace function public.record_apple_purchase(
  p_user_id uuid,
  p_product_id text,
  p_transaction_id text,
  p_original_transaction_id text,
  p_product_kind text,
  p_status text,
  p_started_at timestamptz,
  p_expires_at timestamptz,
  p_auto_renewing boolean,
  p_payload_hash text,
  p_mission_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := p_user_id;
  v_plan_code text;
  v_billing_period public.billing_period;
  v_subscription_id uuid;
  v_subscription_status public.subscription_status;
  v_purchase_status public.purchase_status;
  v_period_start timestamptz;
  v_period_end timestamptz;
  v_existing_start timestamptz;
  v_existing_end timestamptz;
begin
  if auth.role() <> 'service_role' then
    raise exception 'service_role_required';
  end if;
  if nullif(trim(p_transaction_id), '') is null
    or nullif(trim(p_original_transaction_id), '') is null then
    raise exception 'apple_transaction_id_required';
  end if;

  select product.plan_code, plan.billing_period
  into v_plan_code, v_billing_period
  from public.provider_products product
  join public.subscription_plans plan on plan.code = product.plan_code
  where product.provider = 'apple'
    and product.platform = 'ios'
    and product.provider_product_id = p_product_id
    and product.active and plan.active;
  if v_plan_code is null then
    raise exception 'unknown_apple_product';
  end if;
  if (v_billing_period = 'monthly' and p_product_kind <> 'subscription')
    or (v_billing_period = 'none' and p_product_kind <> 'one_time') then
    raise exception 'apple_product_kind_mismatch';
  end if;

  if v_user_id is null then
    if p_product_kind = 'subscription' then
      select user_id into v_user_id
      from public.user_subscriptions
      where provider = 'apple'
        and provider_subscription_id = p_original_transaction_id;
    else
      select user_id into v_user_id
      from public.one_time_purchases
      where provider = 'apple'
        and provider_transaction_id = p_transaction_id;
    end if;
  end if;
  if v_user_id is null then
    return jsonb_build_object('recorded', false, 'reason', 'owner_unknown');
  end if;
  if p_mission_id is not null and not exists (
    select 1 from public.commercial_missions mission
    where mission.id = p_mission_id and mission.owner_user_id = v_user_id
  ) then
    raise exception 'mission_not_owned';
  end if;

  insert into public.payment_events (
    provider,
    provider_event_id,
    event_type,
    payload_hash,
    processed_at
  ) values (
    'apple',
    'transaction:' || p_payload_hash,
    'apple_' || p_product_kind || '_' || p_status,
    p_payload_hash,
    now()
  ) on conflict (provider, provider_event_id) do nothing;

  if p_product_kind = 'subscription' then
    v_subscription_status := case p_status
      when 'active' then 'active'::public.subscription_status
      when 'grace_period' then 'grace_period'::public.subscription_status
      when 'past_due' then 'past_due'::public.subscription_status
      when 'canceled' then 'canceled'::public.subscription_status
      when 'expired' then 'expired'::public.subscription_status
      when 'pending' then 'pending'::public.subscription_status
      when 'refunded' then 'canceled'::public.subscription_status
      else 'failed'::public.subscription_status
    end;
    v_period_start := coalesce(p_started_at, now());
    v_period_end := greatest(
      coalesce(p_expires_at, now() + interval '1 minute'),
      v_period_start + interval '1 second'
    );
    select current_period_start, current_period_end
    into v_existing_start, v_existing_end
    from public.user_subscriptions
    where provider = 'apple'
      and provider_subscription_id = p_original_transaction_id;
    if found then
      if v_period_end > v_existing_end then
        v_period_start := v_existing_end;
      else
        v_period_start := v_existing_start;
      end if;
    end if;

    insert into public.user_subscriptions (
      user_id,
      plan_code,
      provider,
      provider_subscription_id,
      provider_product_id,
      provider_purchase_token,
      status,
      started_at,
      current_period_start,
      current_period_end,
      cancel_at_period_end,
      canceled_at,
      grace_period_end,
      last_verified_at
    ) values (
      v_user_id,
      v_plan_code,
      'apple',
      p_original_transaction_id,
      p_product_id,
      p_transaction_id,
      v_subscription_status,
      coalesce(p_started_at, now()),
      v_period_start,
      v_period_end,
      not coalesce(p_auto_renewing, false),
      case when p_status in ('canceled', 'refunded') then now() else null end,
      case when p_status = 'grace_period'
        then least(v_period_end, now() + interval '7 days') else null end,
      now()
    )
    on conflict (provider, provider_subscription_id) do update
    set
      plan_code = excluded.plan_code,
      provider_product_id = excluded.provider_product_id,
      provider_purchase_token = excluded.provider_purchase_token,
      status = excluded.status,
      current_period_start = excluded.current_period_start,
      current_period_end = excluded.current_period_end,
      cancel_at_period_end = excluded.cancel_at_period_end,
      canceled_at = excluded.canceled_at,
      grace_period_end = excluded.grace_period_end,
      last_verified_at = now()
    returning id into v_subscription_id;

    if v_subscription_status = 'active' then
      insert into public.usage_periods (
        user_id,
        subscription_id,
        period_start,
        period_end
      ) values (
        v_user_id,
        v_subscription_id,
        v_period_start,
        v_period_end
      ) on conflict (subscription_id, period_start, period_end) do nothing;
    end if;
  else
    v_purchase_status := case p_status
      when 'active' then 'verified'::public.purchase_status
      when 'pending' then 'pending'::public.purchase_status
      when 'canceled' then 'canceled'::public.purchase_status
      when 'refunded' then 'refunded'::public.purchase_status
      else 'failed'::public.purchase_status
    end;
    insert into public.one_time_purchases (
      user_id,
      provider,
      provider_transaction_id,
      provider_product_id,
      provider_purchase_token,
      amount_minor,
      currency,
      status,
      mission_id,
      purchased_at,
      verified_at
    )
    select
      v_user_id,
      'apple',
      p_transaction_id,
      p_product_id,
      p_original_transaction_id,
      plan.price_minor,
      plan.currency,
      v_purchase_status,
      p_mission_id,
      coalesce(p_started_at, now()),
      case when v_purchase_status = 'verified' then now() else null end
    from public.subscription_plans plan
    where plan.code = v_plan_code
    on conflict (provider, provider_transaction_id) do update
    set
      mission_id = coalesce(
        public.one_time_purchases.mission_id,
        excluded.mission_id
      ),
      status = case
        when public.one_time_purchases.status = 'assigned'
          and excluded.status = 'verified'
        then 'assigned'::public.purchase_status
        else excluded.status
      end,
      verified_at = excluded.verified_at;
  end if;

  return jsonb_build_object(
    'recorded', true,
    'user_id', v_user_id,
    'plan_code', v_plan_code,
    'status', p_status
  );
end;
$$;

revoke all on function public.record_apple_purchase(
  uuid, text, text, text, text, text,
  timestamptz, timestamptz, boolean, text, uuid
) from public;
grant execute on function public.record_apple_purchase(
  uuid, text, text, text, text, text,
  timestamptz, timestamptz, boolean, text, uuid
) to service_role;

comment on function public.record_apple_purchase(
  uuid, text, text, text, text, text,
  timestamptz, timestamptz, boolean, text, uuid
) is 'Applique uniquement une transaction validée cryptographiquement par le serveur Apple.';

create table public.billing_customers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete restrict,
  provider public.payment_provider not null,
  provider_customer_id text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, provider),
  unique (provider, provider_customer_id)
);

create table public.stripe_checkout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete restrict,
  stripe_session_id text not null unique,
  plan_code text not null references public.subscription_plans (code),
  mission_id uuid references public.commercial_missions (id) on delete restrict,
  product_kind text not null check (product_kind in ('subscription', 'one_time')),
  status text not null default 'open'
    check (status in ('open', 'complete', 'expired', 'failed')),
  idempotency_key text not null,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (user_id, idempotency_key)
);

create table public.billing_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete restrict,
  provider public.payment_provider not null,
  provider_document_id text not null,
  number text not null default '',
  amount_minor bigint not null default 0,
  currency char(3) not null default 'EUR',
  status text not null default '',
  issued_at timestamptz not null,
  hosted_url text,
  pdf_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_document_id),
  constraint billing_documents_amount_positive check (amount_minor >= 0)
);

create trigger billing_customers_set_updated_at
before update on public.billing_customers
for each row execute function public.set_updated_at();

create trigger billing_documents_set_updated_at
before update on public.billing_documents
for each row execute function public.set_updated_at();

insert into public.provider_products (
  plan_code, provider, provider_product_id, platform, active
)
values
  ('mission_unit', 'stripe', 'REPLACE_WITH_STRIPE_PRICE_MISSION', 'windows', false),
  ('solo', 'stripe', 'REPLACE_WITH_STRIPE_PRICE_SOLO', 'windows', false),
  ('pro', 'stripe', 'REPLACE_WITH_STRIPE_PRICE_PRO', 'windows', false)
on conflict (plan_code, provider, platform) do nothing;

create or replace function public.record_stripe_subscription(
  p_event_id text,
  p_user_id uuid,
  p_customer_id text,
  p_subscription_id text,
  p_price_id text,
  p_status text,
  p_started_at timestamptz,
  p_period_start timestamptz,
  p_period_end timestamptz,
  p_cancel_at_period_end boolean,
  p_payload_hash text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := p_user_id;
  v_plan_code text;
  v_status public.subscription_status;
  v_subscription_id uuid;
  v_existing_start timestamptz;
  v_existing_end timestamptz;
begin
  if auth.role() <> 'service_role' then raise exception 'service_role_required'; end if;
  if exists (
    select 1 from public.payment_events
    where provider = 'stripe' and provider_event_id = p_event_id
  ) then
    return jsonb_build_object('recorded', true, 'duplicate', true);
  end if;

  select plan_code into v_plan_code
  from public.provider_products
  where provider = 'stripe' and platform = 'windows'
    and provider_product_id = p_price_id and active;
  if v_plan_code is null then raise exception 'unknown_stripe_price'; end if;

  if v_user_id is null then
    select user_id into v_user_id from public.billing_customers
    where provider = 'stripe' and provider_customer_id = p_customer_id;
  end if;
  if v_user_id is null then return jsonb_build_object('recorded', false, 'reason', 'owner_unknown'); end if;

  insert into public.billing_customers (user_id, provider, provider_customer_id)
  values (v_user_id, 'stripe', p_customer_id)
  on conflict (user_id, provider) do update
  set provider_customer_id = excluded.provider_customer_id;

  v_status := case p_status
    when 'active' then 'active'::public.subscription_status
    when 'past_due' then 'past_due'::public.subscription_status
    when 'unpaid' then 'suspended'::public.subscription_status
    when 'paused' then 'suspended'::public.subscription_status
    when 'canceled' then 'canceled'::public.subscription_status
    when 'incomplete' then 'incomplete'::public.subscription_status
    when 'incomplete_expired' then 'expired'::public.subscription_status
    else 'failed'::public.subscription_status
  end;

  select current_period_start, current_period_end
  into v_existing_start, v_existing_end
  from public.user_subscriptions
  where provider = 'stripe' and provider_subscription_id = p_subscription_id;

  insert into public.user_subscriptions (
    user_id, plan_code, provider, provider_customer_id,
    provider_subscription_id, provider_product_id, status,
    started_at, current_period_start, current_period_end,
    cancel_at_period_end, canceled_at, grace_period_end, last_verified_at
  ) values (
    v_user_id, v_plan_code, 'stripe', p_customer_id,
    p_subscription_id, p_price_id, v_status,
    coalesce(p_started_at, p_period_start), p_period_start, p_period_end,
    coalesce(p_cancel_at_period_end, false),
    case when v_status = 'canceled' then now() else null end,
    case when v_status = 'past_due' then now() + interval '7 days' else null end,
    now()
  )
  on conflict (provider, provider_subscription_id) do update
  set
    plan_code = excluded.plan_code,
    provider_customer_id = excluded.provider_customer_id,
    provider_product_id = excluded.provider_product_id,
    status = excluded.status,
    current_period_start = excluded.current_period_start,
    current_period_end = excluded.current_period_end,
    cancel_at_period_end = excluded.cancel_at_period_end,
    canceled_at = excluded.canceled_at,
    grace_period_end = excluded.grace_period_end,
    last_verified_at = now()
  returning id into v_subscription_id;

  if v_status = 'active' then
    insert into public.usage_periods (
      user_id, subscription_id, period_start, period_end
    ) values (
      v_user_id, v_subscription_id, p_period_start, p_period_end
    ) on conflict (subscription_id, period_start, period_end) do nothing;
  end if;

  insert into public.payment_events (
    provider, provider_event_id, event_type, payload_hash, processed_at
  ) values ('stripe', p_event_id, 'stripe_subscription_' || p_status, p_payload_hash, now());

  return jsonb_build_object('recorded', true, 'user_id', v_user_id, 'status', v_status);
end;
$$;

create or replace function public.record_stripe_one_time_purchase(
  p_event_id text,
  p_user_id uuid,
  p_customer_id text,
  p_session_id text,
  p_transaction_id text,
  p_price_id text,
  p_amount_minor bigint,
  p_currency text,
  p_purchased_at timestamptz,
  p_payload_hash text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_plan_code text;
  v_mission_id uuid;
begin
  if auth.role() <> 'service_role' then raise exception 'service_role_required'; end if;
  if exists (
    select 1 from public.payment_events
    where provider = 'stripe' and provider_event_id = p_event_id
  ) then
    return jsonb_build_object('recorded', true, 'duplicate', true);
  end if;
  select plan_code into v_plan_code from public.provider_products
  where provider = 'stripe' and platform = 'windows'
    and provider_product_id = p_price_id and active;
  if v_plan_code is null then raise exception 'unknown_stripe_price'; end if;
  select mission_id into v_mission_id
  from public.stripe_checkout_sessions
  where stripe_session_id = p_session_id and user_id = p_user_id;

  insert into public.billing_customers (user_id, provider, provider_customer_id)
  values (p_user_id, 'stripe', p_customer_id)
  on conflict (user_id, provider) do update
  set provider_customer_id = excluded.provider_customer_id;

  insert into public.one_time_purchases (
    user_id, provider, provider_transaction_id, provider_product_id,
    amount_minor, currency, status, mission_id, purchased_at, verified_at
  ) values (
    p_user_id, 'stripe', p_transaction_id, p_price_id,
    p_amount_minor, upper(p_currency), 'verified', v_mission_id,
    p_purchased_at, now()
  ) on conflict (provider, provider_transaction_id) do update
  set status = case
    when public.one_time_purchases.status = 'assigned'
    then 'assigned'::public.purchase_status
    else 'verified'::public.purchase_status
  end,
  mission_id = coalesce(
    public.one_time_purchases.mission_id,
    excluded.mission_id
  ),
  verified_at = now();

  update public.stripe_checkout_sessions
  set status = 'complete', completed_at = now()
  where stripe_session_id = p_session_id and user_id = p_user_id;

  insert into public.payment_events (
    provider, provider_event_id, event_type, payload_hash, processed_at
  ) values ('stripe', p_event_id, 'stripe_one_time_paid', p_payload_hash, now());
  return jsonb_build_object('recorded', true, 'user_id', p_user_id);
end;
$$;

create or replace function public.record_stripe_invoice(
  p_event_id text,
  p_customer_id text,
  p_invoice_id text,
  p_number text,
  p_amount_minor bigint,
  p_currency text,
  p_status text,
  p_issued_at timestamptz,
  p_hosted_url text,
  p_pdf_url text,
  p_payload_hash text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare v_user_id uuid;
begin
  if auth.role() <> 'service_role' then raise exception 'service_role_required'; end if;
  select user_id into v_user_id from public.billing_customers
  where provider = 'stripe' and provider_customer_id = p_customer_id;
  if v_user_id is null then return jsonb_build_object('recorded', false, 'reason', 'owner_unknown'); end if;

  insert into public.billing_documents (
    user_id, provider, provider_document_id, number, amount_minor,
    currency, status, issued_at, hosted_url, pdf_url
  ) values (
    v_user_id, 'stripe', p_invoice_id, coalesce(p_number, ''), p_amount_minor,
    upper(p_currency), p_status, p_issued_at, p_hosted_url, p_pdf_url
  ) on conflict (provider, provider_document_id) do update
  set number = excluded.number, amount_minor = excluded.amount_minor,
      status = excluded.status, hosted_url = excluded.hosted_url,
      pdf_url = excluded.pdf_url;

  insert into public.payment_events (
    provider, provider_event_id, event_type, payload_hash, processed_at
  ) values ('stripe', p_event_id, 'stripe_invoice_' || p_status, p_payload_hash, now())
  on conflict (provider, provider_event_id) do nothing;
  return jsonb_build_object('recorded', true, 'user_id', v_user_id);
end;
$$;

revoke all on function public.record_stripe_subscription(text, uuid, text, text, text, text, timestamptz, timestamptz, timestamptz, boolean, text) from public;
revoke all on function public.record_stripe_one_time_purchase(text, uuid, text, text, text, text, bigint, text, timestamptz, text) from public;
revoke all on function public.record_stripe_invoice(text, text, text, text, bigint, text, text, timestamptz, text, text, text) from public;
grant execute on function public.record_stripe_subscription(text, uuid, text, text, text, text, timestamptz, timestamptz, timestamptz, boolean, text) to service_role;
grant execute on function public.record_stripe_one_time_purchase(text, uuid, text, text, text, text, bigint, text, timestamptz, text) to service_role;
grant execute on function public.record_stripe_invoice(text, text, text, text, bigint, text, text, timestamptz, text, text, text) to service_role;

alter table public.billing_customers enable row level security;
alter table public.stripe_checkout_sessions enable row level security;
alter table public.billing_documents enable row level security;

create policy billing_customers_read_owner on public.billing_customers
for select to authenticated using (user_id = auth.uid() or public.is_app_admin(auth.uid()));
create policy stripe_checkout_sessions_read_owner on public.stripe_checkout_sessions
for select to authenticated using (user_id = auth.uid() or public.is_app_admin(auth.uid()));
create policy billing_documents_read_owner on public.billing_documents
for select to authenticated using (user_id = auth.uid() or public.is_app_admin(auth.uid()));

revoke all on public.billing_customers from anon, authenticated;
revoke all on public.stripe_checkout_sessions from anon, authenticated;
revoke all on public.billing_documents from anon, authenticated;
grant select on public.billing_customers to authenticated;
grant select on public.stripe_checkout_sessions to authenticated;
grant select on public.billing_documents to authenticated;

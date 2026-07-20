import { createClient } from 'npm:@supabase/supabase-js@2';

import { stripeRequest } from '../_shared/stripe.ts';

const headers = { 'Content-Type': 'application/json' };

Deno.serve(async (request) => {
  if (request.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'method_not_allowed' }), {
      status: 405,
      headers,
    });
  }
  const authorization = request.headers.get('Authorization');
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!authorization || !supabaseUrl || !anonKey || !serviceKey) {
    return new Response(JSON.stringify({ error: 'not_authenticated' }), {
      status: 401,
      headers,
    });
  }

  try {
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false },
    });
    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) {
      return new Response(JSON.stringify({ error: 'not_authenticated' }), {
        status: 401,
        headers,
      });
    }
    const serviceClient = createClient(supabaseUrl, serviceKey, {
      auth: { persistSession: false },
    });
    const { data: profile } = await serviceClient
      .from('profiles')
      .select('email, account_status')
      .eq('id', authData.user.id)
      .single();
    if (profile?.account_status !== 'active') {
      return new Response(JSON.stringify({ error: 'account_inactive' }), {
        status: 403,
        headers,
      });
    }

    const body = await request.json();
    const planCode = body.planCode;
    const priceId = body.priceId;
    const productKind = body.productKind;
    const missionId = typeof body.missionId === 'string' ? body.missionId : null;
    const idempotencyKey = body.idempotencyKey;
    if (
      typeof planCode !== 'string' ||
      typeof priceId !== 'string' ||
      !['subscription', 'one_time'].includes(productKind) ||
      typeof idempotencyKey !== 'string' ||
      idempotencyKey.length < 12 ||
      idempotencyKey.length > 180
    ) {
      return new Response(JSON.stringify({ error: 'invalid_request' }), {
        status: 400,
        headers,
      });
    }

    const { data: mapping } = await serviceClient
      .from('provider_products')
      .select('plan_code, provider_product_id, subscription_plans(billing_period)')
      .eq('provider', 'stripe')
      .eq('platform', 'windows')
      .eq('active', true)
      .eq('plan_code', planCode)
      .eq('provider_product_id', priceId)
      .maybeSingle();
    const billingPeriod = mapping?.subscription_plans?.billing_period;
    if (
      !mapping ||
      (billingPeriod === 'monthly' && productKind !== 'subscription') ||
      (billingPeriod === 'none' && productKind !== 'one_time')
    ) {
      return new Response(JSON.stringify({ error: 'unknown_stripe_price' }), {
        status: 400,
        headers,
      });
    }

    let { data: customer } = await serviceClient
      .from('billing_customers')
      .select('provider_customer_id')
      .eq('user_id', authData.user.id)
      .eq('provider', 'stripe')
      .maybeSingle();
    if (!customer) {
      const created = await stripeRequest(
        '/customers',
        'POST',
        new URLSearchParams({
          email: profile.email,
          'metadata[user_id]': authData.user.id,
        }),
        `customer:${authData.user.id}`,
      );
      const { data: inserted, error: insertError } = await serviceClient
        .from('billing_customers')
        .upsert({
          user_id: authData.user.id,
          provider: 'stripe',
          provider_customer_id: created.id,
        }, { onConflict: 'user_id,provider' })
        .select('provider_customer_id')
        .single();
      if (insertError) throw insertError;
      customer = inserted;
    }

    const successUrl = Deno.env.get('STRIPE_CHECKOUT_SUCCESS_URL');
    const cancelUrl = Deno.env.get('STRIPE_CHECKOUT_CANCEL_URL');
    if (!successUrl || !cancelUrl) throw new Error('URLs de retour Stripe absentes');
    const parameters = new URLSearchParams({
      mode: productKind === 'subscription' ? 'subscription' : 'payment',
      customer: customer.provider_customer_id,
      client_reference_id: authData.user.id,
      'line_items[0][price]': priceId,
      'line_items[0][quantity]': '1',
      success_url: successUrl,
      cancel_url: cancelUrl,
      'metadata[user_id]': authData.user.id,
      'metadata[plan_code]': planCode,
      'metadata[product_kind]': productKind,
    });
    if (missionId) parameters.set('metadata[mission_id]', missionId);
    if (productKind === 'subscription') {
      parameters.set('subscription_data[metadata][user_id]', authData.user.id);
      parameters.set('subscription_data[metadata][plan_code]', planCode);
    } else {
      parameters.set('payment_intent_data[metadata][user_id]', authData.user.id);
      parameters.set('payment_intent_data[metadata][plan_code]', planCode);
      if (missionId) {
        parameters.set('payment_intent_data[metadata][mission_id]', missionId);
      }
    }
    const session = await stripeRequest(
      '/checkout/sessions',
      'POST',
      parameters,
      `checkout:${authData.user.id}:${idempotencyKey}`,
    );
    const { error: sessionError } = await serviceClient
      .from('stripe_checkout_sessions')
      .upsert({
        user_id: authData.user.id,
        stripe_session_id: session.id,
        plan_code: planCode,
        mission_id: missionId,
        product_kind: productKind,
        status: session.status ?? 'open',
        idempotency_key: idempotencyKey,
      }, { onConflict: 'stripe_session_id' });
    if (sessionError) throw sessionError;

    return new Response(JSON.stringify({
      sessionId: session.id,
      url: session.url,
      status: session.status ?? 'open',
    }), { status: 200, headers });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'checkout_failed',
      message: error instanceof Error ? error.message : String(error),
    }), { status: 500, headers });
  }
});

import { createClient } from 'npm:@supabase/supabase-js@2';

import {
  stripeRequest,
  stripeSha256,
  unixDate,
  verifyStripeSignature,
} from '../_shared/stripe.ts';

const headers = { 'Content-Type': 'application/json' };

Deno.serve(async (request) => {
  const rawBody = await request.text();
  if (!await verifyStripeSignature(rawBody, request.headers.get('Stripe-Signature'))) {
    return new Response(JSON.stringify({ error: 'invalid_signature' }), {
      status: 400,
      headers,
    });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !serviceKey) {
    return new Response(JSON.stringify({ error: 'server_not_configured' }), {
      status: 500,
      headers,
    });
  }
  const serviceClient = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false },
  });

  try {
    const event = JSON.parse(rawBody);
    if (typeof event.id !== 'string' || typeof event.type !== 'string') {
      throw new Error('Événement Stripe invalide');
    }
    const { data: duplicate } = await serviceClient
      .from('payment_events')
      .select('id')
      .eq('provider', 'stripe')
      .eq('provider_event_id', event.id)
      .maybeSingle();
    if (duplicate) {
      return new Response(JSON.stringify({ received: true, duplicate: true }), {
        status: 200,
        headers,
      });
    }

    const object = event.data?.object ?? {};
    if (event.type === 'checkout.session.completed') {
      if (object.mode === 'payment' && object.payment_status === 'paid') {
        const lines = await stripeRequest(
          `/checkout/sessions/${encodeURIComponent(object.id)}/line_items?limit=1`,
        );
        const priceId = lines.data?.[0]?.price?.id;
        const userId = object.metadata?.user_id ?? object.client_reference_id;
        if (!priceId || !userId) throw new Error('Session Stripe incomplète');
        const { error } = await serviceClient.rpc(
          'record_stripe_one_time_purchase',
          {
            p_event_id: `${event.id}:purchase`,
            p_user_id: userId,
            p_customer_id: object.customer,
            p_session_id: object.id,
            p_transaction_id: object.payment_intent ?? object.id,
            p_price_id: priceId,
            p_amount_minor: object.amount_total ?? 0,
            p_currency: object.currency ?? 'eur',
            p_purchased_at: unixDate(object.created),
            p_payload_hash: await stripeSha256(rawBody),
          },
        );
        if (error) throw error;
      } else if (object.mode === 'subscription' && object.subscription) {
        const subscription = await stripeRequest(
          `/subscriptions/${encodeURIComponent(object.subscription)}`,
        );
        await recordSubscription(
          serviceClient,
          `${event.id}:subscription`,
          subscription,
          object.metadata?.user_id ?? object.client_reference_id,
          rawBody,
        );
        await serviceClient
          .from('stripe_checkout_sessions')
          .update({
            status: 'complete',
            completed_at: new Date().toISOString(),
          })
          .eq('stripe_session_id', object.id);
      }
    } else if (
      event.type === 'customer.subscription.created' ||
      event.type === 'customer.subscription.updated' ||
      event.type === 'customer.subscription.deleted'
    ) {
      await recordSubscription(
        serviceClient,
        `${event.id}:subscription`,
        object,
        object.metadata?.user_id ?? null,
        rawBody,
      );
    } else if (
      event.type === 'invoice.paid' ||
      event.type === 'invoice.payment_failed' ||
      event.type === 'invoice.finalized'
    ) {
      const { error } = await serviceClient.rpc('record_stripe_invoice', {
        p_event_id: `${event.id}:invoice`,
        p_customer_id: object.customer,
        p_invoice_id: object.id,
        p_number: object.number ?? '',
        p_amount_minor: object.amount_due ?? 0,
        p_currency: object.currency ?? 'eur',
        p_status: object.status ?? '',
        p_issued_at: unixDate(object.created),
        p_hosted_url: object.hosted_invoice_url,
        p_pdf_url: object.invoice_pdf,
        p_payload_hash: await stripeSha256(rawBody),
      });
      if (error) throw error;

      const subscriptionId = object.subscription ??
        object.parent?.subscription_details?.subscription;
      if (subscriptionId) {
        const subscription = await stripeRequest(
          `/subscriptions/${encodeURIComponent(subscriptionId)}`,
        );
        await recordSubscription(
          serviceClient,
          `${event.id}:subscription`,
          subscription,
          null,
          rawBody,
        );
      }
    }

    await serviceClient.from('payment_events').insert({
      provider: 'stripe',
      provider_event_id: event.id,
      event_type: event.type,
      payload_hash: await stripeSha256(rawBody),
      processed_at: new Date().toISOString(),
    });
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers,
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'webhook_failed',
      message: error instanceof Error ? error.message : String(error),
    }), { status: 500, headers });
  }
});

async function recordSubscription(
  serviceClient: any,
  eventId: string,
  subscription: Record<string, any>,
  userId: string | null,
  rawPayload: string,
): Promise<void> {
  const item = subscription.items?.data?.[0];
  const periodStart = item?.current_period_start ?? subscription.current_period_start;
  const periodEnd = item?.current_period_end ?? subscription.current_period_end;
  const priceId = item?.price?.id;
  if (!priceId || !periodStart || !periodEnd) {
    throw new Error('Abonnement Stripe incomplet');
  }
  const { error } = await serviceClient.rpc('record_stripe_subscription', {
    p_event_id: eventId,
    p_user_id: userId,
    p_customer_id: subscription.customer,
    p_subscription_id: subscription.id,
    p_price_id: priceId,
    p_status: subscription.status,
    p_started_at: unixDate(subscription.start_date ?? periodStart),
    p_period_start: unixDate(periodStart),
    p_period_end: unixDate(periodEnd),
    p_cancel_at_period_end: subscription.cancel_at_period_end ?? false,
    p_payload_hash: await stripeSha256(rawPayload),
  });
  if (error) throw error;
}

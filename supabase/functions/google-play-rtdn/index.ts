import { createClient } from 'npm:@supabase/supabase-js@2';

import {
  GooglePurchaseKind,
  sha256,
  verifyGooglePlayPurchase,
} from '../_shared/google_play.ts';

const headers = { 'Content-Type': 'application/json' };

function decodeMessage(data: string): Record<string, unknown> {
  const normalized = data.replaceAll('-', '+').replaceAll('_', '/');
  return JSON.parse(atob(normalized));
}

Deno.serve(async (request) => {
  const configuredToken = Deno.env.get('GOOGLE_PLAY_RTDN_TOKEN');
  const suppliedToken = request.headers.get('x-constatplus-rtdn-token') ??
    new URL(request.url).searchParams.get('token');
  if (!configuredToken || suppliedToken !== configuredToken) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), {
      status: 401,
      headers,
    });
  }

  try {
    const envelope = await request.json();
    const messageId = envelope?.message?.messageId;
    const encodedData = envelope?.message?.data;
    if (typeof messageId !== 'string' || typeof encodedData !== 'string') {
      return new Response(JSON.stringify({ error: 'invalid_pubsub_message' }), {
        status: 400,
        headers,
      });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    if (!supabaseUrl || !serviceKey) throw new Error('Supabase non configuré');
    const serviceClient = createClient(supabaseUrl, serviceKey, {
      auth: { persistSession: false },
    });
    const eventId = `rtdn:${messageId}`;
    const { data: existing } = await serviceClient
      .from('payment_events')
      .select('id')
      .eq('provider', 'google_play')
      .eq('provider_event_id', eventId)
      .maybeSingle();
    if (existing) {
      return new Response(JSON.stringify({ received: true, duplicate: true }), {
        status: 200,
        headers,
      });
    }

    const notification = decodeMessage(encodedData);
    if (notification.packageName !== Deno.env.get('GOOGLE_PLAY_PACKAGE_NAME')) {
      return new Response(JSON.stringify({ error: 'package_mismatch' }), {
        status: 403,
        headers,
      });
    }
    if (notification.testNotification) {
      await serviceClient.from('payment_events').insert({
        provider: 'google_play',
        provider_event_id: eventId,
        event_type: 'google_play_rtdn_test',
        payload_hash: await sha256(encodedData),
        processed_at: new Date().toISOString(),
      });
      return new Response(JSON.stringify({ received: true, test: true }), {
        status: 200,
        headers,
      });
    }

    const subscription = notification.subscriptionNotification as
      | Record<string, unknown>
      | undefined;
    const oneTime = notification.oneTimeProductNotification as
      | Record<string, unknown>
      | undefined;
    const kind: GooglePurchaseKind = subscription ? 'subscription' : 'one_time';
    const productId = String(
      subscription?.subscriptionId ?? oneTime?.sku ?? '',
    );
    const purchaseToken = String(
      subscription?.purchaseToken ?? oneTime?.purchaseToken ?? '',
    );
    if (!productId || !purchaseToken) {
      throw new Error('Notification Google Play incomplète');
    }

    const purchase = await verifyGooglePlayPurchase(productId, purchaseToken, kind);
    const payloadHash = await sha256(
      `${purchaseToken}:${purchase.transactionId}:${purchase.status}`,
    );
    const { data: recorded, error: recordError } = await serviceClient.rpc(
      'record_google_play_purchase',
      {
        p_user_id: null,
        p_product_id: purchase.productId,
        p_purchase_token: purchase.purchaseToken,
        p_transaction_id: purchase.transactionId,
        p_product_kind: purchase.kind,
        p_status: purchase.status,
        p_started_at: purchase.startedAt,
        p_expires_at: purchase.expiresAt,
        p_auto_renewing: purchase.autoRenewing,
        p_payload_hash: payloadHash,
        p_mission_id: null,
      },
    );
    if (recordError) throw recordError;

    await serviceClient.from('payment_events').insert({
      provider: 'google_play',
      provider_event_id: eventId,
      event_type: `google_play_rtdn_${kind}`,
      payload_hash: await sha256(encodedData),
      processed_at: new Date().toISOString(),
    });
    return new Response(JSON.stringify({ received: true, recorded }), {
      status: 200,
      headers,
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: 'rtdn_failed',
        message: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers },
    );
  }
});

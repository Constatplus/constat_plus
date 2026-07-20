import { createClient } from 'npm:@supabase/supabase-js@2';

import {
  acknowledgeGooglePlayPurchase,
  GooglePurchaseKind,
  sha256,
  verifyGooglePlayPurchase,
} from '../_shared/google_play.ts';

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
    const body = await request.json();
    const productId = body.productId;
    const purchaseToken = body.purchaseToken;
    const productKind = body.productKind as GooglePurchaseKind;
    if (
      typeof productId !== 'string' ||
      typeof purchaseToken !== 'string' ||
      !['subscription', 'one_time'].includes(productKind)
    ) {
      return new Response(JSON.stringify({ error: 'invalid_request' }), {
        status: 400,
        headers,
      });
    }

    const existingTable = productKind === 'subscription'
      ? 'user_subscriptions'
      : 'one_time_purchases';
    const existingIdColumn = productKind === 'subscription'
      ? 'provider_subscription_id'
      : 'provider_transaction_id';
    const { data: existing } = await serviceClient
      .from(existingTable)
      .select(`${existingIdColumn}, status`)
      .eq('user_id', authData.user.id)
      .eq('provider', 'google_play')
      .eq('provider_purchase_token', purchaseToken)
      .maybeSingle();

    let purchase;
    try {
      purchase = await verifyGooglePlayPurchase(
        productId,
        purchaseToken,
        productKind,
      );
    } catch (error) {
      const existingStatus = existing?.status?.toString();
      const alreadyVerified = productKind === 'subscription'
        ? ['active', 'grace_period'].includes(existingStatus)
        : ['verified', 'assigned'].includes(existingStatus);
      if (alreadyVerified) {
        return new Response(
          JSON.stringify({
            verified: true,
            status: 'active',
            transactionId: existing[existingIdColumn],
            message: 'Achat déjà vérifié par le serveur.',
          }),
          { status: 200, headers },
        );
      }
      throw error;
    }
    if (
      purchase.obfuscatedAccountId &&
      purchase.obfuscatedAccountId !== authData.user.id
    ) {
      return new Response(JSON.stringify({ error: 'account_mismatch' }), {
        status: 403,
        headers,
      });
    }

    const payloadHash = await sha256(
      `${purchase.purchaseToken}:${purchase.transactionId}:${purchase.status}`,
    );
    const { data: recorded, error: recordError } = await serviceClient.rpc(
      'record_google_play_purchase',
      {
        p_user_id: authData.user.id,
        p_product_id: purchase.productId,
        p_purchase_token: purchase.purchaseToken,
        p_transaction_id: purchase.transactionId,
        p_product_kind: purchase.kind,
        p_status: purchase.status,
        p_started_at: purchase.startedAt,
        p_expires_at: purchase.expiresAt,
        p_auto_renewing: purchase.autoRenewing,
        p_payload_hash: payloadHash,
        p_mission_id: typeof body.missionId === 'string' ? body.missionId : null,
      },
    );
    if (recordError) throw recordError;

    const verified = ['active', 'grace_period'].includes(purchase.status);
    if (verified) await acknowledgeGooglePlayPurchase(purchase);
    return new Response(
      JSON.stringify({
        verified,
        status: purchase.status === 'pending' ? 'pending' : purchase.status,
        transactionId: purchase.transactionId,
        recorded,
        message: verified
          ? 'Achat vérifié par Google Play.'
          : purchase.status === 'pending'
          ? 'Paiement Google Play en attente.'
          : 'Google Play ne confirme pas un achat actif.',
      }),
      { status: 200, headers },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: 'verification_failed',
        message: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers },
    );
  }
});

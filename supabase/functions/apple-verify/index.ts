import { createClient } from 'npm:@supabase/supabase-js@2';

import {
  ApplePurchaseKind,
  sha256,
  verifyAppleTransaction,
} from '../_shared/apple.ts';

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

    const body = await request.json();
    const productId = body.productId;
    const transactionId = body.transactionId;
    const signedTransaction = body.signedTransaction;
    const productKind = body.productKind as ApplePurchaseKind;
    if (
      typeof productId !== 'string' ||
      typeof transactionId !== 'string' ||
      typeof signedTransaction !== 'string' ||
      !['subscription', 'one_time'].includes(productKind)
    ) {
      return new Response(JSON.stringify({ error: 'invalid_request' }), {
        status: 400,
        headers,
      });
    }

    const purchase = await verifyAppleTransaction(
      transactionId,
      productId,
      productKind,
    );
    const serviceClient = createClient(supabaseUrl, serviceKey, {
      auth: { persistSession: false },
    });
    const existingTable = productKind === 'subscription'
      ? 'user_subscriptions'
      : 'one_time_purchases';
    const existingColumn = productKind === 'subscription'
      ? 'provider_subscription_id'
      : 'provider_transaction_id';
    const existingValue = productKind === 'subscription'
      ? purchase.originalTransactionId
      : purchase.transactionId;
    const { data: existing } = await serviceClient
      .from(existingTable)
      .select('user_id')
      .eq('provider', 'apple')
      .eq(existingColumn, existingValue)
      .maybeSingle();
    if (
      purchase.appAccountToken &&
      purchase.appAccountToken !== authData.user.id
    ) {
      return new Response(JSON.stringify({ error: 'account_mismatch' }), {
        status: 403,
        headers,
      });
    }
    if (
      existing?.user_id &&
      existing.user_id !== authData.user.id
    ) {
      return new Response(JSON.stringify({ error: 'purchase_owner_mismatch' }), {
        status: 403,
        headers,
      });
    }
    if (!purchase.appAccountToken && !existing) {
      return new Response(
        JSON.stringify({
          error: 'apple_account_token_missing',
          message: 'La transaction Apple ne peut pas être liée à ce compte.',
        }),
        { status: 403, headers },
      );
    }

    const payloadHash = await sha256(purchase.rawSignedTransaction);
    const { data: recorded, error: recordError } = await serviceClient.rpc(
      'record_apple_purchase',
      {
        p_user_id: authData.user.id,
        p_product_id: purchase.productId,
        p_transaction_id: purchase.transactionId,
        p_original_transaction_id: purchase.originalTransactionId,
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
    return new Response(
      JSON.stringify({
        verified,
        status: purchase.status,
        transactionId: purchase.transactionId,
        recorded,
        message: verified
          ? 'Achat vérifié par l’App Store.'
          : 'L’App Store ne confirme pas un achat actif.',
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

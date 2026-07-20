import { createClient } from 'npm:@supabase/supabase-js@2';

import {
  ApplePurchaseKind,
  sha256,
  verifyAppleNotification,
} from '../_shared/apple.ts';

const headers = { 'Content-Type': 'application/json' };

function statusForNotification(
  notificationType: string,
  subtype: string,
  expiresDate: number | undefined,
  revoked: boolean,
): string {
  if (revoked || ['REFUND', 'REVOKE'].includes(notificationType)) {
    return 'refunded';
  }
  if (
    ['EXPIRED', 'GRACE_PERIOD_EXPIRED'].includes(notificationType) ||
    (expiresDate != null && expiresDate <= Date.now())
  ) {
    return 'expired';
  }
  if (notificationType === 'DID_FAIL_TO_RENEW') {
    return subtype === 'GRACE_PERIOD' ? 'grace_period' : 'past_due';
  }
  return 'active';
}

Deno.serve(async (request) => {
  if (request.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'method_not_allowed' }), {
      status: 405,
      headers,
    });
  }
  try {
    const body = await request.json();
    if (typeof body.signedPayload !== 'string') {
      return new Response(JSON.stringify({ error: 'invalid_notification' }), {
        status: 400,
        headers,
      });
    }
    const verified = await verifyAppleNotification(body.signedPayload);
    const notificationId = verified.decoded.notificationUUID;
    const notificationType = String(verified.decoded.notificationType ?? 'UNKNOWN');
    const subtype = String(verified.decoded.subtype ?? '');
    if (!notificationId) throw new Error('notificationUUID Apple absent');

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    if (!supabaseUrl || !serviceKey) throw new Error('Supabase non configuré');
    const serviceClient = createClient(supabaseUrl, serviceKey, {
      auth: { persistSession: false },
    });
    const eventId = `notification:${notificationId}`;
    const { data: existing } = await serviceClient
      .from('payment_events')
      .select('id')
      .eq('provider', 'apple')
      .eq('provider_event_id', eventId)
      .maybeSingle();
    if (existing) {
      return new Response(JSON.stringify({ received: true, duplicate: true }), {
        status: 200,
        headers,
      });
    }

    const transaction = verified.transaction;
    let recorded: unknown = null;
    if (transaction?.transactionId && transaction.productId) {
      const kind: ApplePurchaseKind =
        transaction.type === 'Auto-Renewable Subscription'
          ? 'subscription'
          : 'one_time';
      const status = kind === 'one_time' &&
          !['REFUND', 'REVOKE'].includes(notificationType) &&
          transaction.revocationDate == null
        ? 'active'
        : statusForNotification(
            notificationType,
            subtype,
            transaction.expiresDate,
            transaction.revocationDate != null,
          );
      const autoRenewing = kind === 'subscription' &&
        verified.renewal?.autoRenewStatus === 1;
      let ownerId: string | null = null;
      if (transaction.appAccountToken) {
        const { data: profile } = await serviceClient
          .from('profiles')
          .select('id')
          .eq('id', transaction.appAccountToken)
          .maybeSingle();
        ownerId = profile?.id ?? null;
      }
      const { data, error } = await serviceClient.rpc(
        'record_apple_purchase',
        {
          p_user_id: ownerId,
          p_product_id: transaction.productId,
          p_transaction_id: transaction.transactionId,
          p_original_transaction_id:
            transaction.originalTransactionId ?? transaction.transactionId,
          p_product_kind: kind,
          p_status: status,
          p_started_at: new Date(
            transaction.purchaseDate ?? Date.now(),
          ).toISOString(),
          p_expires_at: new Date(
            transaction.expiresDate ?? Date.now() + 60_000,
          ).toISOString(),
          p_auto_renewing: autoRenewing,
          p_payload_hash: await sha256(
            verified.decoded.data?.signedTransactionInfo ?? body.signedPayload,
          ),
          p_mission_id: null,
        },
      );
      if (error) throw error;
      recorded = data;
    }

    const { error: eventError } = await serviceClient
      .from('payment_events')
      .insert({
        provider: 'apple',
        provider_event_id: eventId,
        event_type: `apple_${notificationType.toLowerCase()}`,
        payload_hash: await sha256(body.signedPayload),
        processed_at: new Date().toISOString(),
      });
    if (eventError) throw eventError;
    return new Response(
      JSON.stringify({ received: true, recorded }),
      { status: 200, headers },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: 'apple_notification_failed',
        message: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers },
    );
  }
});

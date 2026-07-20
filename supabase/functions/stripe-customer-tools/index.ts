import { createClient } from 'npm:@supabase/supabase-js@2';

import { stripeRequest } from '../_shared/stripe.ts';

const headers = { 'Content-Type': 'application/json' };

Deno.serve(async (request) => {
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
    const action = body.action;

    if (action === 'checkout_status') {
      const { data: session } = await serviceClient
        .from('stripe_checkout_sessions')
        .select('status, completed_at')
        .eq('user_id', authData.user.id)
        .eq('stripe_session_id', body.sessionId)
        .maybeSingle();
      return new Response(JSON.stringify({
        status: session?.status ?? 'unknown',
        completedAt: session?.completed_at,
      }), { status: 200, headers });
    }

    const { data: customer } = await serviceClient
      .from('billing_customers')
      .select('provider_customer_id')
      .eq('user_id', authData.user.id)
      .eq('provider', 'stripe')
      .maybeSingle();
    if (!customer) {
      return new Response(JSON.stringify({ error: 'stripe_customer_missing' }), {
        status: 404,
        headers,
      });
    }

    if (action === 'portal') {
      const returnUrl = Deno.env.get('STRIPE_PORTAL_RETURN_URL');
      if (!returnUrl) throw new Error('STRIPE_PORTAL_RETURN_URL absent');
      const session = await stripeRequest(
        '/billing_portal/sessions',
        'POST',
        new URLSearchParams({
          customer: customer.provider_customer_id,
          return_url: returnUrl,
        }),
      );
      return new Response(JSON.stringify({ url: session.url }), {
        status: 200,
        headers,
      });
    }

    if (action === 'invoices') {
      const invoices = await stripeRequest(
        `/invoices?customer=${encodeURIComponent(customer.provider_customer_id)}&limit=25`,
      );
      return new Response(JSON.stringify({
        invoices: (invoices.data ?? []).map((invoice: Record<string, any>) => ({
          id: invoice.id,
          number: invoice.number ?? '',
          amount: invoice.amount_due ?? 0,
          currency: String(invoice.currency ?? 'eur').toUpperCase(),
          status: invoice.status ?? '',
          issuedAt: new Date(Number(invoice.created) * 1000).toISOString(),
          hostedUrl: invoice.hosted_invoice_url,
          pdfUrl: invoice.invoice_pdf,
        })),
      }), { status: 200, headers });
    }

    return new Response(JSON.stringify({ error: 'unknown_action' }), {
      status: 400,
      headers,
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'stripe_customer_tools_failed',
      message: error instanceof Error ? error.message : String(error),
    }), { status: 500, headers });
  }
});

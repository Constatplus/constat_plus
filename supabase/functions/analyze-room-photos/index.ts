import { createClient } from 'npm:@supabase/supabase-js@2';

const jsonHeaders = { 'Content-Type': 'application/json' };

Deno.serve(async (request) => {
  if (request.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'method_not_allowed' }), {
      status: 405,
      headers: jsonHeaders,
    });
  }

  const authorization = request.headers.get('Authorization');
  if (!authorization) {
    return new Response(JSON.stringify({ error: 'not_authenticated' }), {
      status: 401,
      headers: jsonHeaders,
    });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const openAiKey = Deno.env.get('OPENAI_API_KEY');
  if (!supabaseUrl || !anonKey || !openAiKey) {
    return new Response(JSON.stringify({ error: 'server_not_configured' }), {
      status: 503,
      headers: jsonHeaders,
    });
  }

  try {
    const body = await request.json();
    const missionId = body.missionId;
    const missionType = body.missionType;
    const idempotencyKey = body.idempotencyKey;
    const openAiRequest = body.openAiRequest;
    if (
      typeof missionId !== 'string' ||
      typeof missionType !== 'string' ||
      typeof idempotencyKey !== 'string' ||
      !openAiRequest ||
      typeof openAiRequest !== 'object'
    ) {
      return new Response(JSON.stringify({ error: 'invalid_request' }), {
        status: 400,
        headers: jsonHeaders,
      });
    }

    const supabase = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false },
    });
    const { data: consumption, error: consumptionError } = await supabase.rpc(
      'consume_ai_analysis',
      {
        p_mission_id: missionId,
        p_mission_type: missionType,
        p_idempotency_key: idempotencyKey,
      },
    );
    if (consumptionError) throw consumptionError;
    if (consumption?.allowed !== true) {
      return new Response(JSON.stringify(consumption), {
        status: 402,
        headers: jsonHeaders,
      });
    }

    const openAiResponse = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${openAiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        ...openAiRequest,
        model: Deno.env.get('OPENAI_VISION_MODEL') ?? 'gpt-4.1-mini',
        max_output_tokens: 1200,
      }),
    });
    const responseText = await openAiResponse.text();
    return new Response(responseText, {
      status: openAiResponse.status,
      headers: jsonHeaders,
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: 'analysis_failed',
        message: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: jsonHeaders },
    );
  }
});

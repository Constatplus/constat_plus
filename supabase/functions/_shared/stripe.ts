const stripeApiBase = 'https://api.stripe.com/v1';

export async function stripeRequest(
  path: string,
  method = 'GET',
  parameters?: URLSearchParams,
  idempotencyKey?: string,
): Promise<Record<string, any>> {
  const secretKey = Deno.env.get('STRIPE_SECRET_KEY');
  if (!secretKey) throw new Error('STRIPE_SECRET_KEY absent');
  const headers = new Headers({ Authorization: `Bearer ${secretKey}` });
  if (method !== 'GET') {
    headers.set('Content-Type', 'application/x-www-form-urlencoded');
  }
  if (idempotencyKey) headers.set('Idempotency-Key', idempotencyKey);
  const response = await fetch(`${stripeApiBase}${path}`, {
    method,
    headers,
    body: method === 'GET' ? undefined : parameters?.toString(),
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.error?.message ?? `Stripe API ${response.status}`);
  }
  return data;
}

export async function verifyStripeSignature(
  payload: string,
  signatureHeader: string | null,
): Promise<boolean> {
  const secret = Deno.env.get('STRIPE_WEBHOOK_SECRET');
  if (!secret || !signatureHeader) return false;
  const values = signatureHeader.split(',').map((part) => part.split('='));
  const timestamp = values.find(([key]) => key === 't')?.[1];
  const signatures = values
    .filter(([key]) => key === 'v1')
    .map(([, value]) => value);
  if (!timestamp || signatures.length === 0) return false;
  if (Math.abs(Date.now() / 1000 - Number(timestamp)) > 300) return false;

  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const digest = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(`${timestamp}.${payload}`),
  );
  const expected = Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
  return signatures.some((signature) => constantTimeEquals(signature, expected));
}

function constantTimeEquals(first: string, second: string): boolean {
  if (first.length !== second.length) return false;
  let difference = 0;
  for (let index = 0; index < first.length; index++) {
    difference |= first.charCodeAt(index) ^ second.charCodeAt(index);
  }
  return difference === 0;
}

export async function stripeSha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(value),
  );
  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

export function unixDate(value: unknown): string {
  return new Date(Number(value ?? Date.now() / 1000) * 1000).toISOString();
}

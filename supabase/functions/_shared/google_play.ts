type GoogleServiceAccount = {
  client_email: string;
  private_key: string;
  token_uri?: string;
};

export type GooglePurchaseKind = 'subscription' | 'one_time';

export type VerifiedGooglePurchase = {
  productId: string;
  purchaseToken: string;
  transactionId: string;
  kind: GooglePurchaseKind;
  status: string;
  startedAt: string;
  expiresAt: string;
  autoRenewing: boolean;
  needsAcknowledgement: boolean;
  obfuscatedAccountId?: string;
  raw: unknown;
};

let cachedToken: { value: string; expiresAt: number } | undefined;

function encodeBase64Url(value: Uint8Array | string): string {
  const bytes = typeof value === 'string'
    ? new TextEncoder().encode(value)
    : value;
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');
}

function decodePem(value: string): Uint8Array {
  const normalized = value
    .replaceAll('\\n', '\n')
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '');
  const binary = atob(normalized);
  return Uint8Array.from(binary, (character) => character.charCodeAt(0));
}

async function accessToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.value;
  }
  const rawAccount = Deno.env.get('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON');
  if (!rawAccount) throw new Error('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON absent');
  const account = JSON.parse(rawAccount) as GoogleServiceAccount;
  const issuedAt = Math.floor(Date.now() / 1000);
  const header = encodeBase64Url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claims = encodeBase64Url(JSON.stringify({
    iss: account.client_email,
    scope: 'https://www.googleapis.com/auth/androidpublisher',
    aud: account.token_uri ?? 'https://oauth2.googleapis.com/token',
    iat: issuedAt,
    exp: issuedAt + 3600,
  }));
  const unsigned = `${header}.${claims}`;
  const key = await crypto.subtle.importKey(
    'pkcs8',
    decodePem(account.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(unsigned),
  );
  const assertion = `${unsigned}.${encodeBase64Url(new Uint8Array(signature))}`;
  const response = await fetch(
    account.token_uri ?? 'https://oauth2.googleapis.com/token',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion,
      }),
    },
  );
  const data = await response.json();
  if (!response.ok || typeof data.access_token !== 'string') {
    throw new Error(`Authentification Google impossible (${response.status})`);
  }
  cachedToken = {
    value: data.access_token,
    expiresAt: Date.now() + Number(data.expires_in ?? 3600) * 1000,
  };
  return cachedToken.value;
}

async function googleRequest(path: string, init?: RequestInit): Promise<unknown> {
  const response = await fetch(`https://androidpublisher.googleapis.com${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${await accessToken()}`,
      'Content-Type': 'application/json',
      ...(init?.headers ?? {}),
    },
  });
  const text = await response.text();
  const data = text ? JSON.parse(text) : {};
  if (!response.ok) {
    throw new Error(`Google Play API ${response.status}: ${text}`);
  }
  return data;
}

function packageName(): string {
  const value = Deno.env.get('GOOGLE_PLAY_PACKAGE_NAME');
  if (!value) throw new Error('GOOGLE_PLAY_PACKAGE_NAME absent');
  return encodeURIComponent(value);
}

export async function verifyGooglePlayPurchase(
  productId: string,
  purchaseToken: string,
  kind: GooglePurchaseKind,
): Promise<VerifiedGooglePurchase> {
  const encodedProduct = encodeURIComponent(productId);
  const encodedToken = encodeURIComponent(purchaseToken);
  if (kind === 'subscription') {
    const raw = await googleRequest(
      `/androidpublisher/v3/applications/${packageName()}/purchases/subscriptionsv2/tokens/${encodedToken}`,
    ) as Record<string, unknown>;
    const lineItems = Array.isArray(raw.lineItems) ? raw.lineItems : [];
    const line = lineItems.find((item) => item?.productId === productId) ?? lineItems[0];
    if (!line || line.productId !== productId) throw new Error('Produit Google Play incohérent');
    const expiresAt = String(line.expiryTime ?? new Date(Date.now() + 60_000).toISOString());
    const expiryDate = new Date(expiresAt);
    const periodStart = new Date(String(raw.startTime ?? new Date().toISOString()));
    const state = String(raw.subscriptionState ?? 'SUBSCRIPTION_STATE_UNSPECIFIED');
    const stillEntitled = expiryDate.getTime() > Date.now();
    const status = state === 'SUBSCRIPTION_STATE_ACTIVE'
      ? 'active'
      : state === 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD'
      ? 'grace_period'
      : state === 'SUBSCRIPTION_STATE_ON_HOLD'
      ? 'past_due'
      : state === 'SUBSCRIPTION_STATE_PAUSED'
      ? 'suspended'
      : state === 'SUBSCRIPTION_STATE_CANCELED' && stillEntitled
      ? 'active'
      : state === 'SUBSCRIPTION_STATE_CANCELED'
      ? 'canceled'
      : state === 'SUBSCRIPTION_STATE_EXPIRED'
      ? 'expired'
      : state === 'SUBSCRIPTION_STATE_PENDING'
      ? 'pending'
      : 'failed';
    const external = raw.externalAccountIdentifiers as Record<string, unknown> | undefined;
    return {
      productId,
      purchaseToken,
      transactionId: String(line.latestSuccessfulOrderId ?? purchaseToken),
      kind,
      status,
      startedAt: periodStart.toISOString(),
      expiresAt,
      autoRenewing: Boolean(line.autoRenewingPlan?.autoRenewEnabled),
      needsAcknowledgement:
        raw.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING',
      obfuscatedAccountId: external?.obfuscatedExternalAccountId?.toString(),
      raw,
    };
  }

  const raw = await googleRequest(
    `/androidpublisher/v3/applications/${packageName()}/purchases/products/${encodedProduct}/tokens/${encodedToken}`,
  ) as Record<string, unknown>;
  const purchaseState = Number(raw.purchaseState ?? -1);
  const startedAt = new Date(Number(raw.purchaseTimeMillis ?? Date.now())).toISOString();
  return {
    productId,
    purchaseToken,
    transactionId: String(raw.orderId ?? purchaseToken),
    kind,
    status: purchaseState === 0 ? 'active' : purchaseState === 2 ? 'pending' : 'canceled',
    startedAt,
    expiresAt: new Date(Date.now() + 60_000).toISOString(),
    autoRenewing: false,
    needsAcknowledgement:
      Number(raw.consumptionState ?? 0) === 0,
    obfuscatedAccountId: raw.obfuscatedExternalAccountId?.toString(),
    raw,
  };
}

export async function acknowledgeGooglePlayPurchase(
  purchase: VerifiedGooglePurchase,
): Promise<void> {
  if (!purchase.needsAcknowledgement) return;
  const product = encodeURIComponent(purchase.productId);
  const token = encodeURIComponent(purchase.purchaseToken);
  if (purchase.kind === 'subscription') {
    await googleRequest(
      `/androidpublisher/v3/applications/${packageName()}/purchases/subscriptions/${product}/tokens/${token}:acknowledge`,
      { method: 'POST', body: '{}' },
    );
  } else {
    await googleRequest(
      `/androidpublisher/v3/applications/${packageName()}/purchases/products/${product}/tokens/${token}:consume`,
      { method: 'POST', body: '{}' },
    );
  }
}

export async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value));
  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

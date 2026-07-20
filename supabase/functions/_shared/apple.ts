import {
  AppStoreServerAPIClient,
  Environment,
  SignedDataVerifier,
} from 'npm:@apple/app-store-server-library@3.1.0';
import { Buffer } from 'node:buffer';

export type ApplePurchaseKind = 'subscription' | 'one_time';

export type VerifiedApplePurchase = {
  productId: string;
  transactionId: string;
  originalTransactionId: string;
  kind: ApplePurchaseKind;
  status: string;
  startedAt: string;
  expiresAt: string;
  autoRenewing: boolean;
  appAccountToken?: string;
  environment: Environment;
  rawSignedTransaction: string;
};

type AppleConfig = {
  privateKey: string;
  keyId: string;
  issuerId: string;
  bundleId: string;
  appAppleId: number;
  roots: Buffer[];
};

let cachedConfig: AppleConfig | undefined;

function config(): AppleConfig {
  if (cachedConfig) return cachedConfig;
  const privateKey = Deno.env.get('APPLE_IAP_PRIVATE_KEY');
  const keyId = Deno.env.get('APPLE_IAP_KEY_ID');
  const issuerId = Deno.env.get('APPLE_IAP_ISSUER_ID');
  const bundleId = Deno.env.get('APPLE_BUNDLE_ID');
  const appAppleId = Number(Deno.env.get('APPLE_APP_ID'));
  const encodedRoots = Deno.env.get('APPLE_ROOT_CERTIFICATES_BASE64');
  if (
    !privateKey || !keyId || !issuerId || !bundleId ||
    !Number.isSafeInteger(appAppleId) || !encodedRoots
  ) {
    throw new Error('Configuration App Store Server incomplète');
  }
  const rootValues = JSON.parse(encodedRoots) as unknown;
  if (!Array.isArray(rootValues) || rootValues.length === 0) {
    throw new Error('Certificats racine Apple absents');
  }
  cachedConfig = {
    privateKey: privateKey.replaceAll('\\n', '\n'),
    keyId,
    issuerId,
    bundleId,
    appAppleId,
    roots: rootValues.map((value) => Buffer.from(String(value), 'base64')),
  };
  return cachedConfig;
}

function client(environment: Environment): AppStoreServerAPIClient {
  const value = config();
  return new AppStoreServerAPIClient(
    value.privateKey,
    value.keyId,
    value.issuerId,
    value.bundleId,
    environment,
  );
}

function verifier(environment: Environment): SignedDataVerifier {
  const value = config();
  return new SignedDataVerifier(
    value.roots,
    true,
    environment,
    value.bundleId,
    environment === Environment.PRODUCTION ? value.appAppleId : undefined,
  );
}

function environmentFromSignedPayload(signedPayload: string): Environment {
  const parts = signedPayload.split('.');
  if (parts.length !== 3) throw new Error('JWS Apple invalide');
  const normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
  const payload = JSON.parse(
    Buffer.from(normalized, 'base64').toString('utf8'),
  ) as Record<string, unknown>;
  const environment = payload.environment ??
    (payload.data as Record<string, unknown> | undefined)?.environment;
  return String(environment).toLowerCase() === 'sandbox'
    ? Environment.SANDBOX
    : Environment.PRODUCTION;
}

function toIso(value: number | undefined, fallback: number): string {
  return new Date(value ?? fallback).toISOString();
}

export async function verifyAppleTransaction(
  transactionId: string,
  expectedProductId: string,
  kind: ApplePurchaseKind,
): Promise<VerifiedApplePurchase> {
  let signedTransaction: string | undefined;
  let environment = Environment.PRODUCTION;
  let storeClient: AppStoreServerAPIClient;
  try {
    storeClient = client(environment);
    signedTransaction = (await storeClient.getTransactionInfo(
      transactionId,
    )).signedTransactionInfo;
  } catch (_) {
    environment = Environment.SANDBOX;
    storeClient = client(environment);
    signedTransaction = (await storeClient.getTransactionInfo(
      transactionId,
    )).signedTransactionInfo;
  }
  if (!signedTransaction) throw new Error('Transaction Apple introuvable');
  const transaction = await verifier(environment).verifyAndDecodeTransaction(
    signedTransaction,
  );
  if (
    transaction.transactionId !== transactionId ||
    transaction.productId !== expectedProductId
  ) {
    throw new Error('Transaction Apple incohérente');
  }
  const actualKind = transaction.type === 'Auto-Renewable Subscription'
    ? 'subscription'
    : 'one_time';
  if (actualKind !== kind) throw new Error('Type de produit Apple incohérent');
  const now = Date.now();
  const revoked = transaction.revocationDate != null;
  const expired = kind === 'subscription' &&
    (transaction.expiresDate ?? 0) <= now;
  let status = revoked ? 'refunded' : expired ? 'expired' : 'active';
  let autoRenewing = false;
  if (kind === 'subscription') {
    const statusResponse = await storeClient.getAllSubscriptionStatuses(
      transaction.originalTransactionId ?? transaction.transactionId,
    );
    const subscription = statusResponse.data
      ?.flatMap((group) => group.lastTransactions ?? [])
      .find((item) =>
        item.originalTransactionId === transaction.originalTransactionId
      );
    status = subscription?.status === 1
      ? 'active'
      : subscription?.status === 4
      ? 'grace_period'
      : subscription?.status === 3
      ? 'past_due'
      : subscription?.status === 5
      ? 'refunded'
      : 'expired';
    if (subscription?.signedRenewalInfo) {
      const renewal = await verifier(environment).verifyAndDecodeRenewalInfo(
        subscription.signedRenewalInfo,
      );
      autoRenewing = renewal.autoRenewStatus === 1;
    }
  }
  return {
    productId: transaction.productId,
    transactionId: transaction.transactionId,
    originalTransactionId:
      transaction.originalTransactionId ?? transaction.transactionId,
    kind,
    status,
    startedAt: toIso(transaction.purchaseDate, now),
    expiresAt: toIso(
      transaction.expiresDate,
      kind === 'subscription' ? now + 60_000 : now + 60_000,
    ),
    autoRenewing,
    appAccountToken: transaction.appAccountToken,
    environment,
    rawSignedTransaction: signedTransaction,
  };
}

export async function verifyAppleNotification(signedPayload: string) {
  const environment = environmentFromSignedPayload(signedPayload);
  const decoded = await verifier(environment).verifyAndDecodeNotification(
    signedPayload,
  );
  const signedTransaction = decoded.data?.signedTransactionInfo;
  const signedRenewal = decoded.data?.signedRenewalInfo;
  const transaction = signedTransaction
    ? await verifier(environment).verifyAndDecodeTransaction(signedTransaction)
    : undefined;
  const renewal = signedRenewal
    ? await verifier(environment).verifyAndDecodeRenewalInfo(signedRenewal)
    : undefined;
  return { decoded, transaction, renewal, environment };
}

export async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(value),
  );
  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

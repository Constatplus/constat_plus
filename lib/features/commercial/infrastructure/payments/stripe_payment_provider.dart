import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/billing_models.dart';
import '../../domain/models/commercial_enums.dart';
import '../../domain/providers/payment_provider.dart';

class StripePaymentProvider implements PaymentProvider {
  StripePaymentProvider._();

  static final StripePaymentProvider instance = StripePaymentProvider._();

  final StreamController<PurchaseUpdate> _updates =
      StreamController<PurchaseUpdate>.broadcast();

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  PaymentProviderKind get kind => PaymentProviderKind.stripe;

  @override
  Stream<PurchaseUpdate> get purchaseUpdates => _updates.stream;

  @override
  Future<bool> isAvailable() async => Platform.isWindows;

  @override
  Future<List<BillingProduct>> loadProducts(Set<String> productIds) async {
    if (!await isAvailable()) return const [];
    return productIds
        .map(
          (id) => BillingProduct(
            id: id,
            planCode: id,
            kind: ProductKind.subscription,
            title: id,
            description: '',
            displayPrice: '',
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<PurchaseResult> purchaseSubscription(PurchaseRequest request) =>
      _openCheckout(request);

  @override
  Future<PurchaseResult> purchaseOneTimeProduct(PurchaseRequest request) =>
      _openCheckout(request);

  Future<PurchaseResult> _openCheckout(PurchaseRequest request) async {
    if (!await isAvailable()) {
      return const PurchaseResult(
        outcome: PurchaseOutcome.failed,
        provider: PaymentProviderKind.stripe,
        message: 'Stripe Checkout est disponible uniquement sur Windows.',
      );
    }
    try {
      final response = await _supabase.functions.invoke(
        'stripe-checkout',
        body: <String, dynamic>{
          'planCode': request.product.planCode,
          'priceId': request.product.id,
          'productKind': request.product.kind == ProductKind.subscription
              ? 'subscription'
              : 'one_time',
          'idempotencyKey': request.idempotencyKey,
          if (request.missionId != null) 'missionId': request.missionId,
        },
      );
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final url = Uri.tryParse(data['url']?.toString() ?? '');
      final sessionId = data['sessionId']?.toString();
      if (response.status != 200 || url == null || sessionId == null) {
        throw StateError(
          data['message']?.toString() ?? 'Session Stripe invalide.',
        );
      }
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw StateError('Impossible d’ouvrir Stripe Checkout.');
      }
      _updates.add(
        PurchaseUpdate(
          provider: kind,
          productId: request.product.id,
          providerTransactionId: sessionId,
          outcome: PurchaseOutcome.pending,
          message: 'Paiement ouvert dans Stripe Checkout.',
        ),
      );
      return PurchaseResult(
        outcome: PurchaseOutcome.pending,
        provider: kind,
        providerTransactionId: sessionId,
        message:
            'Terminez le paiement dans votre navigateur. La confirmation vient du webhook Stripe.',
      );
    } catch (error) {
      return PurchaseResult(
        outcome: PurchaseOutcome.failed,
        provider: kind,
        message: error.toString(),
      );
    }
  }

  Future<String> checkoutStatus(String sessionId) async {
    final response = await _supabase.functions.invoke(
      'stripe-customer-tools',
      body: <String, dynamic>{
        'action': 'checkout_status',
        'sessionId': sessionId,
      },
    );
    if (response.data is Map) {
      return (response.data as Map)['status']?.toString() ?? 'unknown';
    }
    return 'unknown';
  }

  @override
  Future<void> openSubscriptionManagement() async {
    final response = await _supabase.functions.invoke(
      'stripe-customer-tools',
      body: const <String, dynamic>{'action': 'portal'},
    );
    final data = response.data is Map ? response.data as Map : const {};
    final url = Uri.tryParse(data['url']?.toString() ?? '');
    if (response.status != 200 || url == null) {
      throw StateError(
        data['message']?.toString() ?? 'Portail Stripe indisponible.',
      );
    }
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw StateError('Impossible d’ouvrir le portail Stripe.');
    }
  }

  @override
  Future<void> restorePurchases() async {
    throw UnsupportedError(
      'Stripe synchronise les achats par webhooks et ne nécessite pas de restauration locale.',
    );
  }
}

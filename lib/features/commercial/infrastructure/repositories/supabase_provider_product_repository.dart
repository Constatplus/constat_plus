import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/commercial_enums.dart';
import '../../domain/models/provider_product.dart';

class SupabaseProviderProductRepository {
  SupabaseProviderProductRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<ProviderProduct?> findGooglePlayProduct(String planCode) async {
    return _find(
      planCode: planCode,
      provider: 'google_play',
      platform: 'android',
      providerKind: PaymentProviderKind.googlePlay,
      commercialPlatform: CommercialPlatform.android,
    );
  }

  Future<ProviderProduct?> findStripeProduct(String planCode) async {
    return _find(
      planCode: planCode,
      provider: 'stripe',
      platform: 'windows',
      providerKind: PaymentProviderKind.stripe,
      commercialPlatform: CommercialPlatform.windows,
    );
  }

  Future<ProviderProduct?> findAppleProduct(String planCode) async {
    return _find(
      planCode: planCode,
      provider: 'apple',
      platform: 'ios',
      providerKind: PaymentProviderKind.apple,
      commercialPlatform: CommercialPlatform.ios,
    );
  }

  Future<ProviderProduct?> _find({
    required String planCode,
    required String provider,
    required String platform,
    required PaymentProviderKind providerKind,
    required CommercialPlatform commercialPlatform,
  }) async {
    final row = await _client
        .from('provider_products')
        .select()
        .eq('plan_code', planCode)
        .eq('provider', provider)
        .eq('platform', platform)
        .eq('active', true)
        .maybeSingle();
    if (row == null) return null;
    return ProviderProduct(
      id: row['id'] as String,
      planCode: row['plan_code'] as String,
      provider: providerKind,
      platform: commercialPlatform,
      providerProductId: row['provider_product_id'] as String,
      active: row['active'] as bool,
    );
  }
}

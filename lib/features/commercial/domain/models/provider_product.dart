import 'commercial_enums.dart';

class ProviderProduct {
  final String id;
  final String planCode;
  final PaymentProviderKind provider;
  final CommercialPlatform platform;
  final String providerProductId;
  final bool active;

  const ProviderProduct({
    required this.id,
    required this.planCode,
    required this.provider,
    required this.platform,
    required this.providerProductId,
    required this.active,
  });
}

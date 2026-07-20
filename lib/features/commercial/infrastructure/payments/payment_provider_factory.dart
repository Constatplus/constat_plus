import '../../domain/models/commercial_enums.dart';
import '../../domain/providers/payment_provider.dart';
import 'apple_payment_provider.dart';
import 'google_play_payment_provider.dart';
import 'stripe_payment_provider.dart';

class DefaultPaymentProviderFactory implements PaymentProviderFactory {
  const DefaultPaymentProviderFactory();

  @override
  PaymentProvider forPlatform(CommercialPlatform platform) =>
      switch (platform) {
        CommercialPlatform.android => GooglePlayPaymentProvider.instance,
        CommercialPlatform.windows => StripePaymentProvider.instance,
        CommercialPlatform.ios => ApplePaymentProvider.instance,
      };
}

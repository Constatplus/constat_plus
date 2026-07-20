import '../domain/models/commercial_enums.dart';

class CommercialFormatters {
  const CommercialFormatters._();

  static String money(int amountMinor, String currency) {
    final amount = amountMinor / 100;
    final value = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2).replaceAll('.', ',');
    return currency == 'EUR' ? '$value €' : '$value $currency';
  }

  static String provider(PaymentProviderKind provider) {
    return switch (provider) {
      PaymentProviderKind.googlePlay => 'Google Play',
      PaymentProviderKind.stripe => 'Stripe',
      PaymentProviderKind.apple => 'Apple',
      PaymentProviderKind.demo => 'Démonstration',
    };
  }

  static String subscriptionStatus(SubscriptionStatus status) {
    return switch (status) {
      SubscriptionStatus.pending => 'En attente',
      SubscriptionStatus.active => 'Actif',
      SubscriptionStatus.gracePeriod => 'Période de grâce',
      SubscriptionStatus.pastDue => 'Paiement en retard',
      SubscriptionStatus.suspended => 'Suspendu',
      SubscriptionStatus.canceled => 'Annulé',
      SubscriptionStatus.expired => 'Expiré',
      SubscriptionStatus.incomplete => 'Incomplet',
      SubscriptionStatus.failed => 'Échec',
    };
  }

  static String date(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}

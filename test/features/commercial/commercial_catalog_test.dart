import 'dart:ui' show Size;

import 'package:flutter_app/app/app.dart';
import 'package:flutter_app/features/commercial/domain/models/commercial_enums.dart';
import 'package:flutter_app/features/commercial/domain/models/official_pricing_catalog.dart';
import 'package:flutter_app/features/commercial/domain/models/subscription_plan.dart';
import 'package:flutter_app/features/commercial/domain/models/subscription_overview.dart';
import 'package:flutter_app/features/commercial/domain/models/usage_period.dart';
import 'package:flutter_app/features/commercial/domain/repositories/commercial_repositories.dart';
import 'package:flutter_app/features/commercial/infrastructure/repositories/commercial_supabase_mappers.dart';
import 'package:flutter_app/features/commercial/presentation/pages/offers_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 7, 20);

  test('le catalogue Supabase mappe prix, quotas et plateformes', () {
    final plan = CommercialSupabaseMappers.plan({
      'id': 'plan-solo',
      'code': 'solo',
      'name': 'Solo',
      'description': 'Offre Solo',
      'billing_period': 'monthly',
      'price_minor': 9900,
      'currency': 'EUR',
      'mission_quota': 5,
      'ai_analysis_quota': 50,
      'maximum_users': 1,
      'tax_display': 'htva',
      'additional_mission_price_minor': 2000,
      'feature_labels': [
        'Jusqu’à 5 états des lieux par mois',
        '50 analyses IA par mois',
      ],
      'platform_availability': ['android', 'windows', 'ios'],
      'active': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    expect(plan.priceMinor, 9900);
    expect(plan.missionQuota, 5);
    expect(plan.aiAnalysisQuota, 50);
    expect(plan.taxDisplay, PriceTaxDisplay.htva);
    expect(plan.additionalMissionPriceMinor, 2000);
    expect(plan.featureLabels, contains('50 analyses IA par mois'));
    expect(plan.supports(CommercialPlatform.android), isTrue);
  });

  test('la vue abonnement calcule les quotas restants', () {
    final plan = _plan(now);
    final usage = UsagePeriod(
      id: 'usage-1',
      userId: 'user-1',
      periodStart: now,
      periodEnd: now.add(const Duration(days: 30)),
      missionsUsed: 3,
      aiAnalysesUsed: 8,
      createdAt: now,
      updatedAt: now,
    );
    final overview = SubscriptionOverview(
      plan: plan,
      usagePeriod: usage,
      loadedAt: now,
    );

    expect(overview.remainingMissions, 2);
    expect(overview.remainingAiAnalyses, 42);
  });

  testWidgets('la page des offres affiche le catalogue injecté', (
    tester,
  ) async {
    final repository = _FakeCatalogRepository([_plan(now)]);
    await tester.pumpWidget(
      ProjectGeoApp(home: OffersPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Solo'), findsWidgets);
    expect(find.textContaining('69 €'), findsOneWidget);
    expect(find.textContaining('HTVA'), findsWidgets);
    expect(find.text('Jusqu’à 5 états des lieux par mois'), findsOneWidget);
    expect(find.textContaining('7 € HTVA'), findsWidgets);
  });

  test('le tarif annuel professionnel correspond à dix mensualités', () {
    final solo = OfficialPricingCatalog.offers.singleWhere(
      (offer) => offer.code == 'solo',
    );

    expect(solo.priceMinor(PricingPeriod.monthly), 6900);
    expect(solo.priceMinor(PricingPeriod.annual), 69000);
    expect(solo.checkoutCode(PricingPeriod.annual), 'solo_annual');
  });

  testWidgets('le sélecteur affiche les offres Particulier', (tester) async {
    final repository = _FakeCatalogRepository([_plan(now)]);
    await tester.pumpWidget(
      ProjectGeoApp(home: OffersPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Particulier'));
    await tester.pumpAndSettle();

    expect(find.text('Découverte'), findsWidgets);
    expect(find.text('État des lieux IA'), findsWidgets);
    expect(find.textContaining('39 € TVAC'), findsOneWidget);
  });

  testWidgets('l’action de souscription Solo est disponible', (tester) async {
    final repository = _FakeCatalogRepository([_plan(now)]);
    await tester.pumpWidget(
      ProjectGeoApp(home: OffersPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Souscrire à Solo'), findsOneWidget);
  });

  testWidgets('la grille reste sans overflow aux largeurs principales', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final width in [360.0, 800.0, 1440.0]) {
      tester.view.physicalSize = Size(width, 1000);
      await tester.pumpWidget(
        ProjectGeoApp(
          home: OffersPage(repository: _FakeCatalogRepository([_plan(now)])),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'largeur $width px');
    }
  });
}

SubscriptionPlan _plan(DateTime now) {
  return SubscriptionPlan(
    id: 'plan-solo',
    code: 'solo',
    name: 'Solo',
    description: 'Offre Solo',
    billingPeriod: BillingPeriod.monthly,
    priceMinor: 9900,
    currency: 'EUR',
    missionQuota: 5,
    aiAnalysisQuota: 50,
    maximumUsers: 1,
    taxDisplay: PriceTaxDisplay.htva,
    additionalMissionPriceMinor: 2000,
    featureLabels: const <String>[
      'Jusqu’à 5 états des lieux par mois',
      '50 analyses IA par mois',
      'Rapports PDF et Word',
      'Signature électronique',
      'Sauvegarde cloud',
    ],
    platformAvailability: CommercialPlatform.values.toSet(),
    active: true,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeCatalogRepository implements ProductCatalogRepository {
  final List<SubscriptionPlan> plans;

  const _FakeCatalogRepository(this.plans);

  @override
  Future<List<SubscriptionPlan>> getActivePlans() async => plans;

  @override
  Future<SubscriptionPlan?> getPlan(String code) async {
    for (final plan in plans) {
      if (plan.code == code) return plan;
    }
    return null;
  }
}

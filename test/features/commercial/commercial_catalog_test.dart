import 'package:flutter_app/app/app.dart';
import 'package:flutter_app/features/commercial/domain/models/commercial_enums.dart';
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

    expect(find.text('Solo'), findsOneWidget);
    expect(find.textContaining('99 €'), findsOneWidget);
    expect(find.textContaining('HTVA'), findsWidgets);
    expect(find.textContaining('5 états des lieux'), findsOneWidget);
    expect(find.textContaining('20 € HTVA'), findsOneWidget);
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

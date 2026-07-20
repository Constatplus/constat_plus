import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/subscription_overview.dart';
import '../../domain/repositories/commercial_repositories.dart';
import 'commercial_supabase_mappers.dart';

class SupabaseSubscriptionOverviewRepository
    implements SubscriptionOverviewRepository {
  final SupabaseClient _client;

  SupabaseSubscriptionOverviewRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<SubscriptionOverview> loadOverview() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Connectez-vous pour consulter votre offre.');
    }

    final subscriptionRow = await _client
        .from('user_subscriptions')
        .select()
        .eq('user_id', user.id)
        .inFilter('status', const ['active', 'grace_period', 'past_due'])
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    final purchaseRows = await _client
        .from('one_time_purchases')
        .select()
        .eq('user_id', user.id)
        .order('purchased_at', ascending: false);
    final purchases = purchaseRows
        .map(CommercialSupabaseMappers.purchase)
        .toList(growable: false);

    if (subscriptionRow == null) {
      return SubscriptionOverview(
        purchases: purchases,
        loadedAt: DateTime.now().toUtc(),
      );
    }

    final subscription = CommercialSupabaseMappers.subscription(
      subscriptionRow,
    );
    final planRow = await _client
        .from('subscription_plans')
        .select()
        .eq('code', subscription.planCode)
        .single();

    final now = DateTime.now().toUtc().toIso8601String();
    final usageRow = await _client
        .from('usage_periods')
        .select()
        .eq('subscription_id', subscription.id)
        .lte('period_start', now)
        .gt('period_end', now)
        .order('period_end', ascending: false)
        .limit(1)
        .maybeSingle();

    return SubscriptionOverview(
      plan: CommercialSupabaseMappers.plan(planRow),
      subscription: subscription,
      usagePeriod: usageRow == null
          ? null
          : CommercialSupabaseMappers.usagePeriod(usageRow),
      purchases: purchases,
      loadedAt: DateTime.now().toUtc(),
    );
  }
}

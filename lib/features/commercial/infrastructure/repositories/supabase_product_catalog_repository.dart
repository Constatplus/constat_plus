import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/subscription_plan.dart';
import '../../domain/repositories/commercial_repositories.dart';
import 'commercial_supabase_mappers.dart';

class SupabaseProductCatalogRepository implements ProductCatalogRepository {
  final SupabaseClient _client;

  SupabaseProductCatalogRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<List<SubscriptionPlan>> getActivePlans() async {
    final rows = await _client
        .from('subscription_plans')
        .select()
        .eq('active', true)
        .order('sort_order');
    return rows.map(CommercialSupabaseMappers.plan).toList(growable: false);
  }

  @override
  Future<SubscriptionPlan?> getPlan(String code) async {
    final row = await _client
        .from('subscription_plans')
        .select()
        .eq('code', code)
        .eq('active', true)
        .maybeSingle();
    return row == null ? null : CommercialSupabaseMappers.plan(row);
  }
}

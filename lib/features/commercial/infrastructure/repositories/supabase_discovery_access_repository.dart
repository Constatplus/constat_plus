import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/discovery_access_state.dart';
import '../cache/secure_discovery_access_cache.dart';

class SupabaseDiscoveryAccessRepository {
  SupabaseDiscoveryAccessRepository({
    SupabaseClient? client,
    SecureDiscoveryAccessCache? cache,
  }) : _client = client ?? Supabase.instance.client,
       _cache = cache ?? SecureDiscoveryAccessCache();

  final SupabaseClient _client;
  final SecureDiscoveryAccessCache _cache;

  Future<DiscoveryAccessState> getState({bool forceRefresh = false}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Utilisateur non connecté.');
    final now = DateTime.now().toUtc();
    if (!forceRefresh) {
      final cached = await _cache.read(user.id);
      if (cached != null && cached.isFreshAt(now)) return cached;
    }
    try {
      final response = await _client.rpc('get_discovery_access_state');
      final state = DiscoveryAccessState.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
      await _cache.write(state);
      return state;
    } catch (_) {
      final cached = await _cache.read(user.id);
      if (cached != null && cached.isFreshAt(now)) return cached;
      rethrow;
    }
  }

  Future<DiscoveryAccessState> registerMission({
    required String missionId,
    required String missionType,
    bool allowOffline = true,
  }) async {
    final current = await getState();
    if (!current.canCreateMission(missionId)) return current;
    try {
      await _client.rpc(
        'register_discovery_mission',
        params: <String, dynamic>{
          'p_mission_id': missionId,
          'p_mission_type': missionType,
        },
      );
      return getState(forceRefresh: true);
    } catch (_) {
      if (!allowOffline) rethrow;
      final offlineState = current.withActiveMission(missionId);
      await _cache.write(offlineState);
      return offlineState;
    }
  }
}

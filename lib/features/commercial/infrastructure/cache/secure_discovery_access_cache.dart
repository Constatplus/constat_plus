import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/models/discovery_access_state.dart';

class SecureDiscoveryAccessCache {
  SecureDiscoveryAccessCache({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _key(String userId) => 'commercial.discovery_access.$userId';

  Future<DiscoveryAccessState?> read(String userId) async {
    final raw = await _storage.read(key: _key(userId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return DiscoveryAccessState.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      await clear(userId);
      return null;
    }
  }

  Future<void> write(DiscoveryAccessState state) => _storage.write(
    key: _key(state.userId),
    value: jsonEncode(state.toJson()),
  );

  Future<void> clear(String userId) => _storage.delete(key: _key(userId));
}

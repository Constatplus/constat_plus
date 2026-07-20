import 'package:flutter/foundation.dart';

import '../../features/commercial/domain/models/discovery_access_state.dart';

enum AccountPlan { occasional, solo, pro, controller, admin }

class AccessService extends ChangeNotifier {
  AccessService._();

  static final AccessService instance = AccessService._();

  AccountPlan _plan = AccountPlan.occasional;
  bool _isDemo = false;
  String _email = '';
  DiscoveryAccessState? _discoveryAccess;

  AccountPlan get plan => _plan;
  bool get isDemo => _isDemo;
  String get email => _email;
  DiscoveryAccessState? get discoveryAccess => _discoveryAccess;

  bool get isAdmin => _plan == AccountPlan.admin;
  bool get isController => _plan == AccountPlan.controller;
  bool get hasActiveSubscription =>
      _plan == AccountPlan.solo ||
      _plan == AccountPlan.pro ||
      _plan == AccountPlan.controller ||
      _plan == AccountPlan.admin;

  bool hasPaidAccessFor(String missionId) =>
      hasActiveSubscription ||
      (_discoveryAccess?.hasPaidAccessFor(missionId) ?? false);

  bool canOpenRoom(String missionId, int roomIndex) {
    if (hasPaidAccessFor(missionId)) return true;
    final policy = _discoveryAccess?.policy;
    return policy != null && roomIndex < policy.maxFullyDescribedRooms;
  }

  void setDiscoveryAccess(DiscoveryAccessState state) {
    _discoveryAccess = state;
    notifyListeners();
  }

  void startDemo({required AccountPlan plan}) {
    _email = 'demo.${plan.name}@local.constatplus';
    _plan = plan;
    _discoveryAccess = null;
    _isDemo = true;
    notifyListeners();
  }

  void setAuthenticatedAccount({
    required String email,
    required AccountPlan plan,
  }) {
    _email = email;
    _plan = plan;
    _isDemo = false;
    _discoveryAccess = null;
    notifyListeners();
  }

  void signOut() {
    _email = '';
    _plan = AccountPlan.occasional;
    _isDemo = false;
    _discoveryAccess = null;
    notifyListeners();
  }
}

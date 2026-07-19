import 'package:flutter/foundation.dart';

enum AccountPlan { occasional, solo, pro, controller, admin }

class AccessService extends ChangeNotifier {
  AccessService._();

  static final AccessService instance = AccessService._();

  AccountPlan _plan = AccountPlan.occasional;
  bool _missionPaid = false;
  String _email = '';

  AccountPlan get plan => _plan;
  bool get missionPaid => _missionPaid;
  String get email => _email;

  bool get isAdmin => _plan == AccountPlan.admin;
  bool get isController => _plan == AccountPlan.controller;
  bool get hasActiveSubscription =>
      _plan == AccountPlan.solo ||
      _plan == AccountPlan.pro ||
      _plan == AccountPlan.controller ||
      _plan == AccountPlan.admin;

  bool canOpenRoom(int roomIndex) {
    if (hasActiveSubscription || _missionPaid) return true;
    return roomIndex < 3;
  }

  void signIn({required String email, required AccountPlan plan}) {
    _email = email;
    _plan = plan;
    _missionPaid = false;
    notifyListeners();
  }

  void unlockOccasionalMissionForTesting() {
    _missionPaid = true;
    notifyListeners();
  }

  void signOut() {
    _email = '';
    _plan = AccountPlan.occasional;
    _missionPaid = false;
    notifyListeners();
  }
}

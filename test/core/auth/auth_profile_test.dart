import 'package:flutter_app/core/auth/auth_profile.dart';
import 'package:flutter_app/core/auth/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le profil authentifié normalise rôle et statut serveur', () {
    final profile = AuthProfile.fromMap(const {
      'id': 'user-1',
      'email': 'expert@constatplus.be',
      'role': 'controller',
      'account_status': 'active',
    });

    expect(profile.role, UserRole.controller);
    expect(profile.accountStatus, AuthAccountStatus.active);
  });

  test('une valeur inconnue ne donne jamais un rôle privilégié', () {
    final profile = AuthProfile.fromMap(const {
      'id': 'user-1',
      'email': 'user@constatplus.be',
      'role': 'super-admin',
      'account_status': 'unexpected',
    });

    expect(profile.role, UserRole.user);
    expect(profile.accountStatus, AuthAccountStatus.pending);
  });
}

import 'user_role.dart';

enum AuthAccountStatus {
  pending,
  active,
  suspended,
  closed;

  static AuthAccountStatus fromValue(Object? value) {
    return switch (value?.toString().trim().toLowerCase()) {
      'active' => AuthAccountStatus.active,
      'suspended' => AuthAccountStatus.suspended,
      'closed' => AuthAccountStatus.closed,
      _ => AuthAccountStatus.pending,
    };
  }
}

class AuthProfile {
  final String id;
  final String email;
  final UserRole role;
  final AuthAccountStatus accountStatus;

  const AuthProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.accountStatus,
  });

  factory AuthProfile.fromMap(Map<String, dynamic> map) {
    return AuthProfile(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: UserRole.fromValue(map['role']),
      accountStatus: AuthAccountStatus.fromValue(map['account_status']),
    );
  }
}

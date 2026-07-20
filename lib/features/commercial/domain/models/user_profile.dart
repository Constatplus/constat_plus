import 'commercial_enums.dart';

class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String companyName;
  final String companyNumber;
  final String vatNumber;
  final String address;
  final String phone;
  final String professionalTitle;
  final AccountStatus accountStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.companyName = '',
    this.companyNumber = '',
    this.vatNumber = '',
    this.address = '',
    this.phone = '',
    this.professionalTitle = '',
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => '$firstName $lastName'.trim();

  UserProfile copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? companyName,
    String? companyNumber,
    String? vatNumber,
    String? address,
    String? phone,
    String? professionalTitle,
    AccountStatus? accountStatus,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      companyNumber: companyNumber ?? this.companyNumber,
      vatNumber: vatNumber ?? this.vatNumber,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

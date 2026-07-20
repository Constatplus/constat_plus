import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/commercial_enums.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/commercial_repositories.dart';

class UserProfileMapper {
  const UserProfileMapper._();

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      firstName: map['first_name']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      companyName: map['company_name']?.toString() ?? '',
      companyNumber: map['company_number']?.toString() ?? '',
      vatNumber: map['vat_number']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      professionalTitle: map['professional_title']?.toString() ?? '',
      accountStatus: _accountStatus(map['account_status']),
      createdAt: _date(map['created_at']),
      updatedAt: _date(map['updated_at']),
    );
  }

  static Map<String, dynamic> editableFields(UserProfile profile) {
    return <String, dynamic>{
      'first_name': profile.firstName.trim(),
      'last_name': profile.lastName.trim(),
      'company_name': profile.companyName.trim(),
      'company_number': profile.companyNumber.trim(),
      'vat_number': profile.vatNumber.trim(),
      'address': profile.address.trim(),
      'phone': profile.phone.trim(),
      'professional_title': profile.professionalTitle.trim(),
    };
  }

  static DateTime _date(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static AccountStatus _accountStatus(Object? value) {
    return switch (value?.toString().trim().toLowerCase()) {
      'active' => AccountStatus.active,
      'suspended' => AccountStatus.suspended,
      'closed' => AccountStatus.closed,
      _ => AccountStatus.pending,
    };
  }
}

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;

  SupabaseProfileRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<UserProfile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    return data == null ? null : UserProfileMapper.fromMap(data);
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    final user = _client.auth.currentUser;
    if (user == null || user.id != profile.id) {
      throw const AuthException('Aucune session autorisée pour ce profil.');
    }

    final data = await _client
        .from('profiles')
        .update(UserProfileMapper.editableFields(profile))
        .eq('id', user.id)
        .select()
        .single();
    return UserProfileMapper.fromMap(data);
  }
}

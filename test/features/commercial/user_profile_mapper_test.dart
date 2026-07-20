import 'package:flutter_app/features/commercial/domain/models/commercial_enums.dart';
import 'package:flutter_app/features/commercial/infrastructure/repositories/supabase_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mappe un profil Supabase sans exposer les champs privilégiés', () {
    final profile = UserProfileMapper.fromMap(const {
      'id': 'user-1',
      'email': 'gianni@example.be',
      'first_name': 'Gianni',
      'last_name': 'Di Pasquale',
      'company_name': 'Constat+',
      'company_number': 'BE0123456789',
      'vat_number': 'BE0123456789',
      'address': 'Mons',
      'phone': '+32 000 00 00 00',
      'professional_title': 'Géomètre-Expert',
      'account_status': 'active',
      'created_at': '2026-07-20T10:00:00Z',
      'updated_at': '2026-07-20T11:00:00Z',
    });

    final editable = UserProfileMapper.editableFields(profile);

    expect(profile.accountStatus, AccountStatus.active);
    expect(profile.displayName, 'Gianni Di Pasquale');
    expect(profile.vatNumber, 'BE0123456789');
    expect(editable, isNot(contains('role')));
    expect(editable, isNot(contains('account_status')));
    expect(editable, isNot(contains('email')));
  });
}

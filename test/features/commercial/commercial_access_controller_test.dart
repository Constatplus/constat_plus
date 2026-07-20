import 'package:flutter_app/core/access/access_service.dart';
import 'package:flutter_app/features/commercial/application/commercial_access_controller.dart';
import 'package:flutter_app/features/commercial/domain/models/commercial_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(AccessService.instance.signOut);

  test('la démo locale ne peut jamais exporter un rapport définitif', () async {
    AccessService.instance.startDemo(plan: AccountPlan.occasional);

    final result = await CommercialAccessController().authorizeFinalReport(
      missionId: '5dfa855c-f82f-4e79-8499-65dd80a1c788',
      missionType: 'entry',
    );

    expect(result.allowed, isFalse);
    expect(result.reason, EntitlementReason.missionPaymentRequired);
  });
}

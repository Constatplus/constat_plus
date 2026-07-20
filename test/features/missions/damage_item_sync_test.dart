import 'package:flutter_app/core/models/mission.dart';
import 'package:flutter_app/features/missions/services/damage_item_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MissionData mission;
  late RoomData room;

  setUp(() {
    mission = MissionData(
      id: 'mission-1',
      kind: MissionKind.exit,
      createdAt: DateTime(2026),
    );
    room = RoomData(name: 'Séjour', id: 'room-1')
      ..observations = 'Impact visible sur le mur.'
      ..observationsSelectedForDamage = true;
    mission.rooms.add(room);
  });

  test('crée une seule ligne liée à la remarque sélectionnée', () {
    DamageItemSync.synchronize(mission);
    DamageItemSync.synchronize(mission);

    expect(mission.damages, hasLength(1));
    expect(mission.damages.single.room, 'Séjour');
    expect(mission.damages.single.description, room.observations);
    expect(mission.damages.single.sourceRemarkId, 'room-observation:room-1');
  });

  test('actualise la remarque sans perdre les données de calcul', () {
    DamageItemSync.synchronize(mission);
    final damage = mission.damages.single
      ..work = 'Retouche de peinture'
      ..amountExVat = 125
      ..vatRate = .06
      ..depreciation = .75;
    room.observations = 'Deux impacts visibles sur le mur.';

    DamageItemSync.synchronize(mission);

    expect(damage.description, room.observations);
    expect(damage.work, 'Retouche de peinture');
    expect(damage.amountExVat, 125);
    expect(damage.vatRate, .06);
    expect(damage.depreciation, .75);
  });

  test('préserve une description modifiée manuellement', () {
    DamageItemSync.synchronize(mission);
    final damage = mission.damages.single
      ..description = 'Description adaptée par l’expert.';
    room.observations = 'Observation source modifiée.';

    DamageItemSync.synchronize(mission);

    expect(damage.description, 'Description adaptée par l’expert.');
    expect(damage.sourceDescription, room.observations);
  });

  test('conserve les lignes ajoutées manuellement', () {
    mission.damages.add(DamageItem(description: 'Ligne libre'));

    DamageItemSync.synchronize(mission);

    expect(mission.damages, hasLength(2));
    expect(mission.damages.first.description, 'Ligne libre');
  });
}

import '../../../core/models/mission.dart';

class DamageItemSyncResult {
  const DamageItemSyncResult({required this.added, required this.updated});

  final int added;
  final int updated;

  bool get changed => added > 0 || updated > 0;
}

class DamageItemSync {
  const DamageItemSync._();

  static DamageItemSyncResult synchronize(MissionData mission) {
    final bySource = <String, DamageItem>{};
    for (final damage in mission.damages) {
      if (damage.sourceRemarkId.isNotEmpty) {
        bySource.putIfAbsent(damage.sourceRemarkId, () => damage);
      }
    }

    var added = 0;
    var updated = 0;
    for (final room in mission.rooms) {
      final observation = room.observations.trim();
      if (!room.observationsSelectedForDamage || observation.isEmpty) continue;

      final sourceId = 'room-observation:${room.id}';
      final existing = bySource[sourceId];
      if (existing == null) {
        final damage = DamageItem(
          room: room.name,
          description: observation,
          sourceRemarkId: sourceId,
          sourceDescription: observation,
        );
        mission.damages.add(damage);
        bySource[sourceId] = damage;
        added++;
        continue;
      }

      final previousRoom = existing.room;
      final previousSource = existing.sourceDescription;
      final previousDescription = existing.description;
      existing.room = room.name;
      if (existing.description.trim().isEmpty ||
          existing.description == existing.sourceDescription) {
        existing.description = observation;
      }
      existing.sourceDescription = observation;
      if (previousRoom != existing.room ||
          previousSource != existing.sourceDescription ||
          previousDescription != existing.description) {
        updated++;
      }
    }

    return DamageItemSyncResult(added: added, updated: updated);
  }
}

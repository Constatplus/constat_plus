void reorderRooms<T>(List<T> rooms, int oldIndex, int newIndex) {
  if (oldIndex < 0 || oldIndex >= rooms.length) {
    throw RangeError.index(oldIndex, rooms, 'oldIndex');
  }
  if (newIndex < 0 || newIndex > rooms.length) {
    throw RangeError.range(newIndex, 0, rooms.length, 'newIndex');
  }

  var insertionIndex = newIndex;
  if (insertionIndex > oldIndex) insertionIndex--;
  if (insertionIndex == oldIndex) return;

  final room = rooms.removeAt(oldIndex);
  rooms.insert(insertionIndex, room);
}

final Expando<String> _roomIdentityKeys = Expando<String>('roomIdentityKey');
var _nextRoomIdentity = 0;

String roomIdentityKey(Object room) =>
    _roomIdentityKeys[room] ??= 'room-${_nextRoomIdentity++}';

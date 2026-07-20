import 'package:flutter/material.dart';

import 'room_type.dart';

class RoomInfo {
  final RoomType type;
  final String name;
  final IconData icon;
  final Color color;

  const RoomInfo({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
  });
}

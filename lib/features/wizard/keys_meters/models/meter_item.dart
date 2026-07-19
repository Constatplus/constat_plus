import 'package:flutter/material.dart';

class MeterItem {
  final String type;
  final IconData icon;

  String name;
  String number;

  String index;
  String startIndex;
  String endIndex;

  String dayIndex;
  String nightIndex;

  String solarDayIndex;
  String solarNightIndex;

  bool hasPhotovoltaic;

  String observation;

  MeterItem({
    required this.type,
    required this.icon,
    required this.name,
    this.number = '',
    this.index = '',
    this.startIndex = '',
    this.endIndex = '',
    this.dayIndex = '',
    this.nightIndex = '',
    this.solarDayIndex = '',
    this.solarNightIndex = '',
    this.hasPhotovoltaic = false,
    this.observation = '',
  });
}
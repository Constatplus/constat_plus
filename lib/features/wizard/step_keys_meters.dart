import 'package:flutter/material.dart';

import 'keys_meters/models/mission_handover_data.dart';
import 'keys_meters/tabs/documents_tab.dart';
import 'keys_meters/tabs/keys_tab.dart';
import 'keys_meters/tabs/maintenance_tab.dart';
import 'keys_meters/tabs/meters_tab.dart';

class StepKeysMeters extends StatefulWidget {
  const StepKeysMeters({super.key, this.data});

  final MissionHandoverData? data;

  @override
  State<StepKeysMeters> createState() => _StepKeysMetersState();
}

class _StepKeysMetersState extends State<StepKeysMeters> {
  late final MissionHandoverData _fallbackData = MissionHandoverData();

  MissionHandoverData get _data => widget.data ?? _fallbackData;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clés • Compteurs • Documents',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complétez les informations remises avec le bien.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffF4F8FA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(icon: Icon(Icons.key), text: 'Clés'),
                Tab(icon: Icon(Icons.electric_meter), text: 'Compteurs'),
                Tab(icon: Icon(Icons.menu_book), text: 'Documents'),
                Tab(icon: Icon(Icons.build), text: 'Entretiens'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              children: [
                KeysTab(data: _data),
                const MetersTab(),
                const DocumentsTab(),
                const MaintenanceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

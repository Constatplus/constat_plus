import 'package:flutter/material.dart';

import 'keys_meters/tabs/documents_tab.dart';
import 'keys_meters/tabs/keys_tab.dart';
import 'keys_meters/tabs/maintenance_tab.dart';
import 'keys_meters/tabs/meters_tab.dart';

class StepKeysMeters extends StatelessWidget {
  const StepKeysMeters({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return DefaultTabController(
          length: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clés • Compteurs • Documents',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complétez les informations remises avec le bien.',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: isMobile ? 18 : 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8FA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TabBar(
                  isScrollable: isMobile,
                  tabAlignment: isMobile ? TabAlignment.start : TabAlignment.fill,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 10,
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.key_outlined), text: 'Clés'),
                    Tab(
                      icon: Icon(Icons.electric_meter_outlined),
                      text: 'Compteurs',
                    ),
                    Tab(
                      icon: Icon(Icons.menu_book_outlined),
                      text: 'Documents',
                    ),
                    Tab(icon: Icon(Icons.build_outlined), text: 'Entretiens'),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              const Expanded(
                child: TabBarView(
                  children: [
                    KeysTab(),
                    MetersTab(),
                    DocumentsTab(),
                    MaintenanceTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

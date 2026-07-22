class MissionHandoverData {
  final List<KeyHandoverItem> keys = <KeyHandoverItem>[];
  final List<DocumentHandoverItem> documents = <DocumentHandoverItem>[];
  final List<MaintenanceHandoverItem> maintenance = <MaintenanceHandoverItem>[];

  List<String> get keyReportLines => keys
      .map((item) {
        final details = <String>[
          '${item.quantity} × ${item.name}',
          if (item.observation.trim().isNotEmpty) item.observation.trim(),
        ];
        return details.join(' — ');
      })
      .toList(growable: false);

  List<String> get documentReportLines => documents
      .where((item) => item.selected)
      .map((item) {
        final observation = item.observation.trim();
        return observation.isEmpty ? item.name : '${item.name} — $observation';
      })
      .toList(growable: false);

  List<String> get maintenanceReportLines => maintenance
      .where((item) => item.selected)
      .map((item) {
        final details = <String>[item.name];
        if (item.date != null) {
          final date = item.date!;
          details.add(
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
          );
        }
        if (item.company.trim().isNotEmpty) details.add(item.company.trim());
        if (item.observation.trim().isNotEmpty) {
          details.add(item.observation.trim());
        }
        return details.join(' — ');
      })
      .toList(growable: false);

  List<String> get manualReportLines => documents
      .where((item) => item.selected)
      .map((item) => item.name)
      .toList(growable: false);
}

class KeyHandoverItem {
  KeyHandoverItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.observation = '',
  });

  final String id;
  String name;
  int quantity;
  String observation;
}

class DocumentHandoverItem {
  DocumentHandoverItem({required this.name})
    : id = '${DateTime.now().microsecondsSinceEpoch}-$name';

  final String id;
  final String name;
  bool selected = false;
  String observation = '';
}

class MaintenanceHandoverItem {
  MaintenanceHandoverItem({required this.name})
    : id = '${DateTime.now().microsecondsSinceEpoch}-$name';

  final String id;
  final String name;
  bool selected = false;
  DateTime? date;
  String company = '';
  String observation = '';
}

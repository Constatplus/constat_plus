import 'package:flutter/material.dart';

class InspectionPage extends StatefulWidget {
  const InspectionPage({super.key});

  @override
  State<InspectionPage> createState() => _InspectionPageState();
}

class _InspectionPageState extends State<InspectionPage> {
  final List<String> rooms = [
    'Hall d’entrée',
    'Séjour',
    'Cuisine',
    'WC',
    'Salle de bain',
    'Chambre 1',
    'Chambre 2',
  ];

  final List<String> sections = [
    'Sol',
    'Murs',
    'Plafond',
    'Menuiseries',
    'Électricité',
    'Chauffage',
    'Observations',
  ];

  int selectedRoomIndex = 0;
  String selectedSection = 'Sol';

  final Map<String, TextEditingController> controllers = {};

  TextEditingController _controllerFor(String room, String section) {
    final key = '$room-$section';
    controllers.putIfAbsent(key, () => TextEditingController());
    return controllers[key]!;
  }

  void _nextRoom() {
    if (selectedRoomIndex < rooms.length - 1) {
      setState(() {
        selectedRoomIndex++;
        selectedSection = 'Sol';
      });
    }
  }

  void _previousRoom() {
    if (selectedRoomIndex > 0) {
      setState(() {
        selectedRoomIndex--;
        selectedSection = 'Sol';
      });
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoom = rooms[selectedRoomIndex];
    final progress = (selectedRoomIndex + 1) / rooms.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      appBar: AppBar(
        title: const Text('Mode visite'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          Container(
            width: 260,
            color: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedRoomIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: const Color(0xFFE3F2FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? const Color(0xFF1565C0) : Colors.grey,
                    ),
                    title: Text(
                      rooms[index],
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedRoomIndex = index;
                        selectedSection = 'Sol';
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentRoom,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pièce ${selectedRoomIndex + 1} / ${rooms.length}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: progress, minHeight: 10),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: sections.map((section) {
                      final isSelected = section == selectedSection;

                      return ChoiceChip(
                        label: Text(section),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedSection = section;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    selectedSection,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _controllerFor(currentRoom, selectedSection),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText:
                            'Décris ici l’état du ${selectedSection.toLowerCase()} pour : $currentRoom',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: selectedRoomIndex == 0
                            ? null
                            : _previousRoom,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Pièce précédente'),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: selectedRoomIndex == rooms.length - 1
                            ? null
                            : _nextRoom,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Pièce suivante'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

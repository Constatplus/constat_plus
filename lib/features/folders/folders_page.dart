import 'package:flutter/material.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  int selectedTab = 0;
  String searchText = '';

  final List<InventoryFolderPreview> folders = [
    InventoryFolderPreview(
      propertyType: 'Appartement',
      address: 'Rue de la Gare 25',
      city: '7000 Mons',
      tenant: 'Jean Dupont',
      owner: 'Marie Lambert',
      status: FolderStatus.inProgress,
      updatedAt: '03/07/2026',
    ),
    InventoryFolderPreview(
      propertyType: 'Maison',
      address: 'Avenue du Pont Rouge 19',
      city: '7000 Mons',
      tenant: 'Sophie Martin',
      owner: 'Paul Durand',
      status: FolderStatus.draft,
      updatedAt: '02/07/2026',
    ),
    InventoryFolderPreview(
      propertyType: 'Studio',
      address: 'Rue de Nimy 12',
      city: '7000 Mons',
      tenant: 'Lucas Petit',
      owner: 'Anne Dubois',
      status: FolderStatus.completed,
      updatedAt: '01/07/2026',
    ),
  ];

  List<InventoryFolderPreview> get filteredFolders {
    return folders.where((folder) {
      final matchesTab = selectedTab == 0
          ? folder.status != FolderStatus.completed
          : folder.status == FolderStatus.completed;

      final query = searchText.toLowerCase();

      final matchesSearch =
          folder.address.toLowerCase().contains(query) ||
          folder.city.toLowerCase().contains(query) ||
          folder.tenant.toLowerCase().contains(query) ||
          folder.owner.toLowerCase().contains(query);

      return matchesTab && matchesSearch;
    }).toList();
  }

  void _openFolderMenu(InventoryFolderPreview folder) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Continuer'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Renommer'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Dupliquer'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Exporter PDF'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToNewInventory() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final visibleFolders = filteredFolders;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8FA),
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Mes dossiers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un dossier...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _TabButton(
                  label: 'En cours',
                  selected: selectedTab == 0,
                  onTap: () {
                    setState(() {
                      selectedTab = 0;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _TabButton(
                  label: 'Terminés',
                  selected: selectedTab == 1,
                  onTap: () {
                    setState(() {
                      selectedTab = 1;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: visibleFolders.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun dossier trouvé',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: visibleFolders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final folder = visibleFolders[index];

                        return _FolderCard(
                          folder: folder,
                          onMenuTap: () => _openFolderMenu(folder),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        onPressed: _goToNewInventory,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.black87 : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final InventoryFolderPreview folder;
  final VoidCallback onMenuTap;

  const _FolderCard({
    required this.folder,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onMenuTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                folder.propertyType,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(folder.address),
              Text(folder.city),
              const SizedBox(height: 16),
              Text('Locataire : ${folder.tenant}'),
              Text('Propriétaire : ${folder.owner}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: folder.statusColor,
                  ),
                  const SizedBox(width: 8),
                  Text(folder.statusLabel),
                  const Spacer(),
                  Text(
                    'Modifié le ${folder.updatedAt}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InventoryFolderPreview {
  final String propertyType;
  final String address;
  final String city;
  final String tenant;
  final String owner;
  final FolderStatus status;
  final String updatedAt;

  InventoryFolderPreview({
    required this.propertyType,
    required this.address,
    required this.city,
    required this.tenant,
    required this.owner,
    required this.status,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case FolderStatus.draft:
        return 'Brouillon';
      case FolderStatus.inProgress:
        return 'En cours';
      case FolderStatus.completed:
        return 'Terminé';
    }
  }

  Color get statusColor {
    switch (status) {
      case FolderStatus.draft:
        return Colors.redAccent;
      case FolderStatus.inProgress:
        return Colors.orange;
      case FolderStatus.completed:
        return Colors.green;
    }
  }
}

enum FolderStatus {
  draft,
  inProgress,
  completed,
}

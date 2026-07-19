import 'package:flutter/material.dart';
import 'general_information_page.dart';

class PropertyTypePage extends StatelessWidget {
  const PropertyTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final types = [
      ['Appartement', Icons.apartment, 'Logement en copropriété'],
      ['Maison', Icons.house, 'Habitation individuelle'],
      ['Studio', Icons.home_outlined, 'Petit logement'],
      ['Garage / Box', Icons.garage, 'Emplacement fermé'],
      ['Commerce', Icons.store, 'Local commercial'],
      ['Bureau', Icons.business, 'Espace professionnel'],
      ['Entrepôt', Icons.warehouse, 'Local de stockage'],
      ['Autre', Icons.more_horiz, 'Bien spécifique'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Nature du bien')),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const Text(
            'Quel type de bien ?',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sélectionnez la catégorie correspondant au bien.',
            style: TextStyle(fontSize: 17, color: Colors.black54),
          ),
          const SizedBox(height: 28),
          for (final type in types)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PropertyTypeTile(
                title: type[0] as String,
                icon: type[1] as IconData,
                subtitle: type[2] as String,
              ),
            ),
        ],
      ),
    );
  }
}

class _PropertyTypeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;

  const _PropertyTypeTile({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GeneralInformationPage(propertyType: title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFE6F3F6),
                child: Icon(icon, color: const Color(0xFF0F5F73)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
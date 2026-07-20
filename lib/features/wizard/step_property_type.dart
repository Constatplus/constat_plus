import 'package:flutter/material.dart';

class StepPropertyType extends StatefulWidget {
  const StepPropertyType({super.key});

  @override
  State<StepPropertyType> createState() => _StepPropertyTypeState();
}

class _StepPropertyTypeState extends State<StepPropertyType> {
  String? selectedType;

  final List<_PropertyType> types = const [
    _PropertyType(
      'Maison',
      'Bien complet avec façades et extérieurs',
      Icons.home_rounded,
    ),
    _PropertyType(
      'Appartement',
      'Lot privatif dans un immeuble',
      Icons.apartment_rounded,
    ),
    _PropertyType(
      'Studio',
      'Petite unité avec espace unique',
      Icons.king_bed_rounded,
    ),
    _PropertyType(
      'Commerce',
      'Surface commerciale ou magasin',
      Icons.storefront_rounded,
    ),
    _PropertyType(
      'Bureau',
      'Local professionnel ou administratif',
      Icons.business_center_rounded,
    ),
    _PropertyType(
      'Garage',
      'Garage, box ou emplacement fermé',
      Icons.garage_rounded,
    ),
    _PropertyType(
      'Immeuble',
      'Plusieurs niveaux ou plusieurs lots',
      Icons.location_city_rounded,
    ),
    _PropertyType(
      'Autre',
      'Bien spécifique ou personnalisé',
      Icons.add_circle_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de bien',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choisissez le type de bien à visiter.',
          style: TextStyle(fontSize: 17, color: Colors.black54),
        ),
        const SizedBox(height: 28),
        Expanded(
          child: GridView.builder(
            itemCount: types.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final type = types[index];
              final selected = selectedType == type.name;

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  setState(() {
                    selectedType = type.name;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFEAF2FF) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1565C0)
                          : Colors.grey.shade300,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFF4F8FA),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          type.icon,
                          color: selected ? Colors.white : Colors.black87,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: selected
                                    ? const Color(0xFF1565C0)
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              type.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF1565C0),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PropertyType {
  final String name;
  final String description;
  final IconData icon;

  const _PropertyType(this.name, this.description, this.icon);
}

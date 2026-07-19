import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'step_signatures.dart';

class StepExitMissionOrder extends StatefulWidget {
  const StepExitMissionOrder({super.key});

  @override
  State<StepExitMissionOrder> createState() => _StepExitMissionOrderState();
}

class _StepExitMissionOrderState extends State<StepExitMissionOrder> {
  final ImagePicker _picker = ImagePicker();
  XFile? _missionPhoto;

  bool _ownerSelected = true;
  bool _tenantSelected = true;
  bool _ownerRepresentative = false;
  bool _tenantRepresentative = false;
  bool _expertSelected = true;

  String _feePayer = 'Chaque partie';
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _tenantController = TextEditingController();
  final TextEditingController _ownerRepresentativeController = TextEditingController();
  final TextEditingController _tenantRepresentativeController = TextEditingController();
  final TextEditingController _missionScopeController = TextEditingController(
    text: 'Réaliser contradictoirement l’état des lieux de sortie, relever les observations, les clés, les index et les entretiens, établir le procès-verbal, chiffrer les dégâts locatifs et proposer une indemnité compensatoire.',
  );

  final SignaturesData _signatures = SignaturesData();

  Future<void> _takeMissionPhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo != null && mounted) setState(() => _missionPhoto = photo);
  }

  Future<void> _chooseMissionPhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (photo != null && mounted) setState(() => _missionPhoto = photo);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _ownerController.dispose();
    _tenantController.dispose();
    _ownerRepresentativeController.dispose();
    _tenantRepresentativeController.dispose();
    _missionScopeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('Ordre de mission', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text(
          'Photographiez un ordre de mission signé sur papier ou utilisez le texte proposé ci-dessous.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        _section(
          title: 'Ordre de mission papier',
          icon: Icons.document_scanner_outlined,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 12, runSpacing: 12, children: [
              FilledButton.icon(onPressed: _takeMissionPhoto, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Prendre une photo')),
              OutlinedButton.icon(onPressed: _chooseMissionPhoto, icon: const Icon(Icons.photo_library_outlined), label: const Text('Choisir une photo')),
              if (_missionPhoto != null)
                TextButton.icon(onPressed: () => setState(() => _missionPhoto = null), icon: const Icon(Icons.delete_outline), label: const Text('Supprimer')),
            ]),
            if (_missionPhoto != null) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(_missionPhoto!.path), height: 220, width: 320, fit: BoxFit.cover),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 18),
        _section(
          title: 'Parties à la mission',
          icon: Icons.groups_outlined,
          child: Column(children: [
            CheckboxListTile(contentPadding: EdgeInsets.zero, value: _ownerSelected, onChanged: (v) => setState(() => _ownerSelected = v ?? false), title: const Text('Bailleur'), subtitle: TextField(controller: _ownerController, decoration: _input('Nom du bailleur'))),
            CheckboxListTile(contentPadding: EdgeInsets.zero, value: _tenantSelected, onChanged: (v) => setState(() => _tenantSelected = v ?? false), title: const Text('Preneur / locataire'), subtitle: TextField(controller: _tenantController, decoration: _input('Nom du preneur'))),
            CheckboxListTile(contentPadding: EdgeInsets.zero, value: _ownerRepresentative, onChanged: (v) => setState(() => _ownerRepresentative = v ?? false), title: const Text('Représentant du bailleur'), subtitle: TextField(controller: _ownerRepresentativeController, decoration: _input('Nom et qualité'))),
            CheckboxListTile(contentPadding: EdgeInsets.zero, value: _tenantRepresentative, onChanged: (v) => setState(() => _tenantRepresentative = v ?? false), title: const Text('Représentant du preneur'), subtitle: TextField(controller: _tenantRepresentativeController, decoration: _input('Nom et qualité'))),
            CheckboxListTile(contentPadding: EdgeInsets.zero, value: _expertSelected, onChanged: (v) => setState(() => _expertSelected = v ?? false), title: const Text('Expert désigné par les parties')),
          ]),
        ),
        const SizedBox(height: 18),
        _section(
          title: 'Honoraires',
          icon: Icons.payments_outlined,
          child: Wrap(spacing: 16, runSpacing: 16, children: [
            SizedBox(
              width: 300,
              child: DropdownButtonFormField<String>(
                initialValue: _feePayer,
                decoration: _input('Honoraires supportés par'),
                items: const ['Chaque partie', 'Bailleur', 'Preneur / locataire'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _feePayer = v ?? _feePayer),
              ),
            ),
            SizedBox(width: 260, child: TextField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _input('Prix convenu (€ TVAC)'))),
          ]),
        ),
        const SizedBox(height: 18),
        _section(
          title: 'Texte de l’ordre de mission',
          icon: Icons.assignment_turned_in_outlined,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Les parties soussignées donnent mission à l’expert désigné de procéder contradictoirement à l’état des lieux de sortie du bien concerné. Elles l’autorisent à accéder aux lieux, à effectuer toutes constatations utiles, à prendre des photographies, à relever les compteurs, à inventorier les clés, documents et entretiens, à recueillir les déclarations des parties, à comparer l’état du bien avec le procès-verbal d’entrée et le bail, à établir le procès-verbal de sortie, à chiffrer les éventuels dégâts locatifs et à proposer une indemnité compensatoire.\n\nLes parties reconnaissent que les honoraires sont dus à la fin de la mission, selon la répartition et le prix convenus ci-dessus. Elles sont informées qu’un procès-verbal de sortie et, le cas échéant, un calcul d’indemnité compensatoire seront établis à l’issue de la visite. La signature de l’ordre de mission autorise l’expert à accomplir ces opérations dans le respect de son indépendance, de sa neutralité et des règles professionnelles applicables. Le refus ou l’absence de signature d’une partie n’empêche pas l’expert de consigner les faits observés et la position de chacun dans son rapport.',
              style: TextStyle(height: 1.55),
            ),
            const SizedBox(height: 16),
            TextField(controller: _missionScopeController, minLines: 3, maxLines: 7, decoration: _input('Fonctions complémentaires / étendue particulière de la mission')),
          ]),
        ),
        const SizedBox(height: 18),
        _section(
          title: 'Signature de l’ordre de mission',
          icon: Icons.draw_outlined,
          child: StepSignatures(data: _signatures, includeExpert: true, embedded: true),
        ),
      ],
    );
  }

  Widget _section({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: const Color(0xFF2563EB)), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  InputDecoration _input(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)));
}

import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'entry_pdf_viewer_page.dart';
import 'property_composition/models/room_item.dart';

class StepExitComparison extends StatefulWidget {
  const StepExitComparison({super.key, required this.rooms});

  final List<RoomItem> rooms;

  @override
  State<StepExitComparison> createState() => _StepExitComparisonState();
}

class _StepExitComparisonState extends State<StepExitComparison> {
  static const List<String> _posts = <String>[
    'Sol',
    'Plafond',
    'Mur avant',
    'Mur droit',
    'Mur arrière',
    'Mur gauche',
    'Menuiseries',
    'Électricité',
    'Porte',
    'Radiateur',
    'Châssis',
    'Sanitaires',
    'Mobilier',
    'Autre',
  ];

  final List<_ExitRemark> _remarks = <_ExitRemark>[_ExitRemark()];
  Uint8List? _entryPdfBytes;
  String? _entryPdfName;
  bool _isPickingPdf = false;

  Future<void> _pickEntryPdf() async {
    if (_isPickingPdf) return;

    setState(() => _isPickingPdf = true);
    try {
      const pdfGroup = XTypeGroup(
        label: "État des lieux d'entrée (PDF)",
        extensions: <String>['pdf'],
        mimeTypes: <String>['application/pdf'],
      );
      final file = await openFile(
        acceptedTypeGroups: const <XTypeGroup>[pdfGroup],
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _entryPdfBytes = bytes;
        _entryPdfName = file.name;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de sélectionner le PDF : $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingPdf = false);
      }
    }
  }

  Future<void> _openEntryPdf() async {
    final bytes = _entryPdfBytes;
    final name = _entryPdfName;
    if (bytes == null || name == null) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EntryPdfViewerPage(pdfBytes: bytes, fileName: name),
      ),
    );
  }

  void _addRemark() {
    setState(() => _remarks.add(_ExitRemark()));
  }

  void _removeRemark(int index) {
    if (_remarks.length == 1) return;
    setState(() {
      _remarks[index].dispose();
      _remarks.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final remark in _remarks) {
      remark.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomNames = widget.rooms.map((room) => room.name).toList();

    return ListView(
      children: <Widget>[
        const Text(
          'Remarques comparatives de sortie',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          "L'état des lieux d'entrée reste la référence. Ajoutez uniquement les différences constatées lors de la sortie.",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.picture_as_pdf_outlined,
                color: Color(0xFF1D4ED8),
              ),
              SizedBox(
                width: 280,
                child: Text(
                  _entryPdfName ?? "Aucun PDF d'entrée sélectionné",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isPickingPdf ? null : _pickEntryPdf,
                icon: _isPickingPdf
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file_outlined),
                label: Text(
                  _entryPdfBytes == null
                      ? "Sélectionner le PDF d'entrée"
                      : 'Remplacer le PDF',
                ),
              ),
              FilledButton.icon(
                onPressed: _entryPdfBytes == null ? null : _openEntryPdf,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text("Consulter l'état des lieux d'entrée"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (roomNames.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: const Text(
              "Aucune pièce n'est disponible. Revenez à l'étape précédente pour reprendre la composition du rapport d'entrée.",
            ),
          ),
        for (var i = 0; i < _remarks.length; i++) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Remarque ${i + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Supprimer',
                      onPressed: () => _removeRemark(i),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    SizedBox(
                      width: 300,
                      child: DropdownButtonFormField<String>(
                        initialValue: roomNames.contains(_remarks[i].room)
                            ? _remarks[i].room
                            : null,
                        decoration: _input('Pièce concernée'),
                        items: roomNames
                            .map(
                              (name) => DropdownMenuItem<String>(
                                value: name,
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _remarks[i].room = value),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: DropdownButtonFormField<String>(
                        initialValue: _remarks[i].post,
                        decoration: _input('Poste concerné'),
                        items: _posts
                            .map(
                              (post) => DropdownMenuItem<String>(
                                value: post,
                                child: Text(post),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _remarks[i].post = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _remarks[i].description,
                  minLines: 3,
                  maxLines: 8,
                  decoration: _input('Remarque constatée à la sortie').copyWith(
                    hintText:
                        'Ex. Présence de deux griffes verticales sur le mur droit.',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Ajouter des photos'),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "La description d'entrée n'est pas modifiée.",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _addRemark,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une remarque'),
          ),
        ),
      ],
    );
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class _ExitRemark {
  String? room;
  String? post;
  final TextEditingController description = TextEditingController();

  void dispose() {
    description.dispose();
  }
}

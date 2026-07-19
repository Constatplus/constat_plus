import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class EntryPdfViewerPage extends StatelessWidget {
  const EntryPdfViewerPage({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  final Uint8List pdfBytes;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF334155),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour au rapport de sortie'),
            ),
          ),
        ],
      ),
      body: SafeArea(child: PdfViewer.data(pdfBytes, sourceName: fileName)),
    );
  }
}

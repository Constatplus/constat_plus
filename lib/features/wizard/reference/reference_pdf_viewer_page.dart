import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class ReferencePdfViewerPage extends StatelessWidget {
  const ReferencePdfViewerPage({
    super.key,
    required this.title,
    required this.backLabel,
    this.pdfBytes,
    this.pdfPath,
  }) : assert(pdfBytes != null || pdfPath != null);

  final String title;
  final String backLabel;
  final Uint8List? pdfBytes;
  final String? pdfPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF334155),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(backLabel),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: pdfBytes != null
            ? PdfViewer.data(pdfBytes!, sourceName: title)
            : PdfViewer.file(pdfPath!),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class EntryPdfViewerPage extends StatelessWidget {
  const EntryPdfViewerPage({
    super.key,
    required this.pdfPath,
    required this.fileName,
  });

  final String pdfPath;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
         
import 'package:flutter/material.dart';

import '../models/report_document.dart';

/// Renders the neutral [ReportDocument] model as a Flutter preview.
///
/// No business data is assembled here. This class only translates shared
/// report blocks into widgets, so the preview can progressively replace the
/// former report-specific layout.
class FlutterReportRenderer extends StatelessWidget {
  const FlutterReportRenderer({
    super.key,
    required this.document,
    this.photoBuilder,
    this.pageWidth = 794,
    this.pageBackgroundColor = Colors.white,
    this.previewBackgroundColor = const Color(0xFFEFF3F5),
  });

  final ReportDocument document;

  /// Lets the host application decide how local, network or cached images are
  /// loaded. A placeholder is displayed when no builder is provided.
  final Widget Function(BuildContext context, ReportPhoto photo)? photoBuilder;

  /// A4-like width at 96 dpi. The preview remains responsive on small screens.
  final double pageWidth;
  final Color pageBackgroundColor;
  final Color previewBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = document.theme;
    final margin = _millimetresToLogicalPixels(theme.pageMarginMm);

    return ColoredBox(
      color: previewBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: pageWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: pageBackgroundColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 22,
                    offset: Offset(0, 8),
                    color: Color(0x22000000),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(margin),
                child: DefaultTextStyle(
                  style: _bodyStyle(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final section in document.enabledSections)
                        _buildSection(context, section),
                      if (theme.footerText.isNotEmpty) _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, ReportSection section) {
    return Padding(
      padding: EdgeInsets.only(
        top: section.startOnNewPage ? 40 : 0,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (section.title.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(section.title, style: _headingStyle(level: 1)),
            ),
          for (final block in section.blocks) _buildBlock(context, block),
        ],
      ),
    );
  }

  Widget _buildBlock(BuildContext context, ReportBlock block) {
    if (block is ReportHeadingBlock) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(block.text, style: _headingStyle(level: block.level)),
      );
    }

    if (block is ReportParagraphBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          block.text,
          textAlign: block.justified ? TextAlign.justify : TextAlign.start,
          style: _bodyStyle().copyWith(
            fontWeight: block.bold ? FontWeight.w700 : FontWeight.w400,
            fontStyle: block.italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      );
    }

    if (block is ReportKeyValueBlock) {
      return _buildKeyValue(block);
    }

    if (block is ReportDescriptionTableBlock) {
      return _buildDescriptionTable(block);
    }

    if (block is ReportPhotoGridBlock) {
      return _buildPhotoGrid(context, block);
    }

    if (block is ReportCalculationTableBlock) {
      return _buildCalculationTable(block);
    }

    if (block is ReportSignatureBlock) {
      return _buildSignatures(block);
    }

    if (block is ReportPageBreakBlock) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Divider(height: 1),
      );
    }

    if (block is ReportSpacerBlock) {
      return SizedBox(height: block.height);
    }

    return const SizedBox.shrink();
  }

  Widget _buildKeyValue(ReportKeyValueBlock block) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: block.emphasized
            ? _color(document.theme.secondaryColorHex).withValues(alpha: .16)
            : null,
        border: Border.all(color: const Color(0xFFD9E0E4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.hasBoundedWidth && constraints.maxWidth < 430;
          if (compact || !constraints.hasBoundedWidth) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.label,
                  style: _bodyStyle().copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(block.value, style: _bodyStyle()),
              ],
            );
          }

          return Table(
            columnWidths: const {
              0: FixedColumnWidth(170),
              1: FlexColumnWidth(),
            },
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      block.label,
                      style: _bodyStyle().copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(block.value, style: _bodyStyle()),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDescriptionTable(ReportDescriptionTableBlock block) {
    final rows = <TableRow>[];
    final hasCondition = block.rows.any((row) => row.condition != null);

    for (final row in block.rows) {
      rows.add(
        TableRow(
          children: [
            _tableCell(row.label, bold: true),
            _tableCell(row.description),
            if (hasCondition) _tableCell(row.condition ?? ''),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Table(
        border: TableBorder.all(color: const Color(0xFFD9E0E4)),
        columnWidths: {
          0: FlexColumnWidth(block.firstColumnRatio),
          1: FlexColumnWidth(hasCondition ? .52 : 1 - block.firstColumnRatio),
          if (hasCondition) 2: const FlexColumnWidth(.20),
        },
        children: rows,
      ),
    );
  }

  Widget _buildPhotoGrid(
    BuildContext context,
    ReportPhotoGridBlock block,
  ) {
    if (block.photos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 12.0;
          final boundedWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : pageWidth;
          final useTwoColumns = boundedWidth >= 520;
          final itemWidth = useTwoColumns
              ? (boundedWidth - spacing) / 2
              : boundedWidth;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var index = 0; index < block.photos.length; index++)
                SizedBox(
                  width: itemWidth,
                  child: _buildPhotoCard(
                    context,
                    block.photos[index],
                    index: index,
                    showCaption: block.showCaptions,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhotoCard(
    BuildContext context,
    ReportPhoto photo, {
    required int index,
    required bool showCaption,
  }) {
    final caption = photo.caption.trim().isEmpty
        ? 'Photo ${index + 1}'
        : 'Photo ${index + 1} - ${photo.caption.trim()}';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9E0E4)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 3),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: photoBuilder?.call(context, photo) ??
                const ColoredBox(
                  color: Color(0xFFF2F5F6),
                  child: Center(child: Icon(Icons.photo_outlined, size: 36)),
                ),
          ),
          if (showCaption)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _bodyStyle().copyWith(
                  fontSize: document.theme.bodyFontSize - 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalculationTable(ReportCalculationTableBlock block) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Table(
        border: TableBorder.all(color: const Color(0xFFD9E0E4)),
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(2),
        },
        children: [
          for (final row in block.rows)
            TableRow(
              children: [
                _tableCell(row.label),
                _tableCell(row.calculation),
                _tableCell(
                  _money(row.amount, block.currency),
                  alignRight: true,
                ),
              ],
            ),
          TableRow(
            decoration: BoxDecoration(
              color: _color(document.theme.primaryColorHex).withValues(alpha: .10),
            ),
            children: [
              _tableCell(block.totalLabel, bold: true),
              _tableCell('', bold: true),
              _tableCell(
                _money(block.totalAmount, block.currency),
                bold: true,
                alignRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignatures(ReportSignatureBlock block) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final signatory in block.signatories)
          SizedBox(
            width: 220,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD9E0E4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signatory.role,
                    style: _bodyStyle().copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(signatory.name, style: _bodyStyle()),
                  const SizedBox(height: 44),
                  const Divider(height: 1),
                  const SizedBox(height: 5),
                  Text(
                    signatory.signedAt == null ? 'Signature' : 'Signé',
                    style: _bodyStyle().copyWith(fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          const Divider(),
          Text(
            document.theme.footerText,
            textAlign: TextAlign.center,
            style: _bodyStyle().copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _tableCell(
    String text, {
    bool bold = false,
    bool alignRight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.start,
        style: _bodyStyle().copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }

  TextStyle _bodyStyle() {
    return TextStyle(
      fontFamily: document.theme.fontFamily,
      fontSize: document.theme.bodyFontSize,
      height: 1.35,
      color: _color(document.theme.bodyColorHex),
    );
  }

  TextStyle _headingStyle({required int level}) {
    final baseSize = level <= 1
        ? document.theme.headingFontSize
        : document.theme.headingFontSize - (level - 1) * 1.5;
    return TextStyle(
      fontFamily: document.theme.fontFamily,
      fontSize: baseSize.clamp(document.theme.bodyFontSize, 40).toDouble(),
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: _color(document.theme.headingColorHex),
    );
  }

  static double _millimetresToLogicalPixels(double millimetres) {
    return millimetres * 96 / 25.4;
  }

  static Color _color(String hex) {
    final normalized = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$normalized', radix: 16));
  }

  static String _money(double value, String currency) {
    final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
    return '$formatted $currency';
  }
}

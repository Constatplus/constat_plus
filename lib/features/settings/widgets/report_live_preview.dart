import 'package:flutter/material.dart';

import '../models/report_preferences.dart';

enum ReportPreviewPage {
  cover('Couverture', Icons.description_outlined),
  notes('Notes liminaires', Icons.notes_outlined),
  room('Pièce', Icons.meeting_room_outlined),
  calculations('Calculs', Icons.calculate_outlined),
  annexes('Annexes', Icons.photo_library_outlined);

  const ReportPreviewPage(this.label, this.icon);

  final String label;
  final IconData icon;
}

class ReportLivePreview extends StatelessWidget {
  const ReportLivePreview({
    super.key,
    required this.preferences,
    required this.page,
    required this.zoom,
    required this.onPageChanged,
    required this.onZoomChanged,
  });

  final ReportPreferences preferences;
  final ReportPreviewPage page;
  final double zoom;
  final ValueChanged<ReportPreviewPage> onPageChanged;
  final ValueChanged<double> onZoomChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _toolbar(context),
          const Divider(height: 1),
          Expanded(
            child: Container(
              color: const Color(0xFFE8EDF2),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 595 * zoom,
                    height: 842 * zoom,
                    child: Transform.scale(
                      scale: zoom,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 595,
                        height: 842,
                        child: _a4Page(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownButton<ReportPreviewPage>(
            value: page,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            items: ReportPreviewPage.values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(item.label),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onPageChanged(value);
            },
          ),
          IconButton.outlined(
            tooltip: 'Réduire',
            onPressed: zoom <= .5
                ? null
                : () => onZoomChanged((zoom - .25).clamp(.5, 1.5).toDouble()),
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 58,
            child: Text(
              '${(zoom * 100).round()} %',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          IconButton.outlined(
            tooltip: 'Agrandir',
            onPressed: zoom >= 1.5
                ? null
                : () => onZoomChanged((zoom + .25).clamp(.5, 1.5).toDouble()),
            icon: const Icon(Icons.add),
          ),
          TextButton(
            onPressed: () => onZoomChanged(.75),
            child: const Text('Adapter'),
          ),
        ],
      ),
    );
  }

  Widget _a4Page() {
    final margin = (preferences.pageMarginMm * 2.2)
        .clamp(22.0, 78.0)
        .toDouble();
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(margin, margin, margin, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: page == ReportPreviewPage.cover
                  ? _pageContent()
                  : ClipRect(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: _pageContent(),
                      ),
                    ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _pageContent() {
    return switch (page) {
      ReportPreviewPage.cover => _cover(),
      ReportPreviewPage.notes => _notes(),
      ReportPreviewPage.room => _room(),
      ReportPreviewPage.calculations => _calculations(),
      ReportPreviewPage.annexes => _annexes(),
    };
  }

  Widget _cover() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: preferences.showLogo
              ? _logoPlaceholder()
              : const SizedBox(height: 54),
        ),
        const Spacer(),
        Text(
          'ÉTAT DES LIEUX\nD’ENTRÉE',
          textAlign: TextAlign.center,
          style: _textStyle(
            size: preferences.titleFontSize,
            color: _color(preferences.primaryColorHex),
            weight: FontWeight.w800,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 18),
        Container(height: 3, color: _color(preferences.secondaryColorHex)),
        const SizedBox(height: 28),
        Text(
          'Appartement – 19 Avenue du Pont Rouge\n7000 Mons',
          textAlign: TextAlign.center,
          style: _textStyle(
            size: preferences.headingFontSize,
            color: _color(preferences.headingColorHex),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 44),
        _informationBox('Date de la visite', '18 juillet 2026'),
        const SizedBox(height: 10),
        _informationBox('Propriétaire', 'Monsieur et Madame Exemple'),
        const SizedBox(height: 10),
        _informationBox('Locataire', 'Monsieur Exemple'),
        const Spacer(flex: 2),
        Text(
          preferences.companyName.isEmpty
              ? 'Votre société'
              : preferences.companyName,
          textAlign: TextAlign.center,
          style: _textStyle(
            size: preferences.headingFontSize,
            color: _color(preferences.headingColorHex),
            weight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          preferences.professionalNumber,
          textAlign: TextAlign.center,
          style: _bodyStyle(size: 10),
        ),
      ],
    );
  }

  Widget _notes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _documentHeader('NOTES LIMINAIRES'),
        const SizedBox(height: 26),
        Text(
          preferences.entryPreliminaryNotes,
          textAlign: TextAlign.justify,
          style: _bodyStyle(height: 1.5),
        ),
        const SizedBox(height: 26),
        _sectionTitle('PRINCIPES DE CONSTATATION'),
        const SizedBox(height: 12),
        Text(
          'Le présent constat porte sur les éléments visibles et accessibles au jour de la visite. Les descriptions sont établies selon l’orientation depuis la porte d’entrée de chaque pièce.',
          textAlign: TextAlign.justify,
          style: _bodyStyle(height: 1.5),
        ),
        const SizedBox(height: 24),
        _sectionTitle('CONSERVATION DES DOCUMENTS'),
        const SizedBox(height: 12),
        Text(
          'Les parties sont invitées à conserver le présent rapport, ses annexes photographiques et les justificatifs utiles pendant toute la durée de l’occupation.',
          textAlign: TextAlign.justify,
          style: _bodyStyle(height: 1.5),
        ),
      ],
    );
  }

  Widget _room() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _documentHeader('SÉJOUR'),
        const SizedBox(height: 22),
        _sectionTitle('DESCRIPTION GÉNÉRALE'),
        const SizedBox(height: 12),
        _descriptionRow(
          'Sol',
          'Carrelage de teinte grise, propre et en bon état général.',
        ),
        _descriptionRow(
          'Plafond',
          'Peinture blanche mate, uniforme et conforme aux généralités.',
        ),
        _descriptionRow(
          'Mur avant',
          'Peinture blanche. Deux percements millimétriques à proximité de l’angle droit.',
        ),
        _descriptionRow(
          'Mur droit',
          'Peinture blanche légèrement souillée en partie basse.',
        ),
        _descriptionRow(
          'Mur arrière',
          'Peinture blanche, sans observation particulière.',
        ),
        _descriptionRow(
          'Mur gauche',
          'Peinture blanche présentant une fine griffe horizontale.',
        ),
        const SizedBox(height: 18),
        _sectionTitle('ÉQUIPEMENTS'),
        const SizedBox(height: 12),
        _descriptionRow(
          'Électricité',
          'Quatre prises simples, deux interrupteurs et un point lumineux fonctionnel.',
        ),
        _descriptionRow(
          'Chauffage',
          'Radiateur panneau peint en blanc, propre et fonctionnel.',
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _photoPlaceholder('Photo 01')),
            const SizedBox(width: 12),
            Expanded(child: _photoPlaceholder('Photo 02')),
          ],
        ),
      ],
    );
  }

  Widget _calculations() {
    final border = BorderSide(
      color: _color(preferences.primaryColorHex).withValues(alpha: .35),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _documentHeader('CALCUL DES INDEMNITÉS'),
        const SizedBox(height: 22),
        Table(
          border: TableBorder(horizontalInside: border, bottom: border),
          columnWidths: const {
            0: FlexColumnWidth(2.2),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(1),
          },
          children: [
            _tableRow(['Poste', 'Base de calcul', 'TVAC'], header: true),
            _tableRow([
              'Remise en peinture – séjour',
              '18,00 m² × 20,00 €',
              '381,60 €',
            ]),
            _tableRow(['Nettoyage menuiseries', 'Forfait', '84,80 €']),
            _tableRow(['Remplacement cache-prise', '2 × 12,00 €', '29,04 €']),
          ],
        ),
        const SizedBox(height: 28),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _color(preferences.primaryColorHex).withValues(alpha: .08),
              border: Border.all(color: _color(preferences.primaryColorHex)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL TVAC',
                  style: _textStyle(
                    size: preferences.headingFontSize,
                    weight: FontWeight.bold,
                  ),
                ),
                Text(
                  '495,44 €',
                  style: _textStyle(
                    size: preferences.headingFontSize,
                    color: _color(preferences.primaryColorHex),
                    weight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _annexes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _documentHeader('ANNEXES PHOTOGRAPHIQUES'),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: _photoPlaceholder('Photo 01 – Séjour')),
            const SizedBox(width: 12),
            Expanded(child: _photoPlaceholder('Photo 02 – Séjour')),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _photoPlaceholder('Photo 03 – Cuisine')),
            const SizedBox(width: 12),
            Expanded(child: _photoPlaceholder('Photo 04 – Chambre')),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Les photographies font partie intégrante du présent rapport. Elles illustrent les constatations décrites sans s’y substituer.',
          textAlign: TextAlign.justify,
          style: _bodyStyle(height: 1.45),
        ),
      ],
    );
  }

  Widget _documentHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (preferences.showLogo) _logoPlaceholder(compact: true),
            const Spacer(),
            Text(
              preferences.companyName,
              style: _bodyStyle(
                size: 9,
                color: _color(preferences.headingColorHex),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: _textStyle(
            size: preferences.titleFontSize,
            color: _color(preferences.primaryColorHex),
            weight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 3, color: _color(preferences.secondaryColorHex)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _color(preferences.primaryColorHex).withValues(alpha: .08),
        border: Border(
          left: BorderSide(
            color: _color(preferences.secondaryColorHex),
            width: 4,
          ),
        ),
      ),
      child: Text(
        title,
        style: _textStyle(
          size: preferences.headingFontSize,
          color: _color(preferences.headingColorHex),
          weight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _descriptionRow(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: _bodyStyle(height: 1.38),
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }

  Widget _informationBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: Border.all(
          color: _color(preferences.primaryColorHex).withValues(alpha: .35),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 135,
            child: Text(label, style: _bodyStyle(weight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, style: _bodyStyle())),
        ],
      ),
    );
  }

  Widget _logoPlaceholder({bool compact = false}) {
    return Container(
      width: compact ? 76 : 112,
      height: compact ? 34 : 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _color(preferences.primaryColorHex).withValues(alpha: .08),
        border: Border.all(color: _color(preferences.primaryColorHex)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'LOGO',
        style: _textStyle(
          size: compact ? 9 : 11,
          color: _color(preferences.primaryColorHex),
          weight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _photoPlaceholder(String caption) {
    return Column(
      children: [
        Container(
          height: 132,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Icon(
            Icons.photo_outlined,
            size: 38,
            color: _color(preferences.primaryColorHex),
          ),
        ),
        const SizedBox(height: 6),
        Text(caption, textAlign: TextAlign.center, style: _bodyStyle(size: 8)),
      ],
    );
  }

  TableRow _tableRow(List<String> values, {bool header = false}) {
    return TableRow(
      decoration: header
          ? BoxDecoration(
              color: _color(preferences.primaryColorHex).withValues(alpha: .1),
            )
          : null,
      children: values
          .map(
            (value) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              child: Text(
                value,
                style: _bodyStyle(
                  size: 9,
                  weight: header ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _footer() {
    return Column(
      children: [
        Divider(
          color: _color(preferences.primaryColorHex).withValues(alpha: .35),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                preferences.footerText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _bodyStyle(
                  size: 8,
                  color: _color(preferences.bodyColorHex).withValues(alpha: .7),
                ),
              ),
            ),
            if (preferences.showPageNumbers)
              Text(
                'Page ${page.index + 1} / ${ReportPreviewPage.values.length}',
                style: _bodyStyle(
                  size: 8,
                  color: _color(preferences.bodyColorHex).withValues(alpha: .7),
                ),
              ),
          ],
        ),
      ],
    );
  }

  TextStyle _bodyStyle({
    double? size,
    double? height,
    Color? color,
    FontWeight? weight,
  }) {
    return _textStyle(
      size: size ?? preferences.bodyFontSize,
      height: height,
      color: color ?? _color(preferences.bodyColorHex),
      weight: weight,
    );
  }

  TextStyle _textStyle({
    double? size,
    double? height,
    Color? color,
    FontWeight? weight,
  }) {
    return TextStyle(
      fontFamily: preferences.fontFamily,
      fontSize: size,
      height: height,
      color: color,
      fontWeight: weight,
    );
  }

  static Color _color(String value) {
    final clean = value.replaceAll('#', '').trim().toUpperCase();
    final valid = RegExp(r'^[0-9A-F]{6}$').hasMatch(clean) ? clean : '1E5AA8';
    return Color(int.parse('FF$valid', radix: 16));
  }
}

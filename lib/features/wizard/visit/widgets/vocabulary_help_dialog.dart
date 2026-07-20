import 'package:flutter/material.dart';

import '../../../../core/ai/local_technical_knowledge.dart';
import '../../../../core/ai/offline_inspection_ai_service.dart';

class VocabularyHelpDialog extends StatefulWidget {
  const VocabularyHelpDialog({
    super.key,
    required this.knowledge,
    required this.missionType,
    required this.element,
    this.initialQuery = '',
  });

  final LocalTechnicalKnowledge knowledge;
  final String missionType;
  final String element;
  final String initialQuery;

  static Future<String?> show(
    BuildContext context, {
    required String missionType,
    required String element,
    String initialQuery = '',
    LocalTechnicalKnowledge? knowledge,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => VocabularyHelpDialog(
        knowledge: knowledge ?? LocalTechnicalKnowledge(),
        missionType: missionType,
        element: element,
        initialQuery: initialQuery,
      ),
    );
  }

  @override
  State<VocabularyHelpDialog> createState() => _VocabularyHelpDialogState();
}

class _VocabularyHelpDialogState extends State<VocabularyHelpDialog> {
  late final TextEditingController _searchController;
  final _sentenceController = TextEditingController();
  List<String> _categories = const [];
  List<TechnicalKnowledgeTerm> _results = const [];
  TechnicalKnowledgeTerm? _selectedTerm;
  String? _category;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sentenceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final categories = await widget.knowledge.categories(
      missionType: widget.missionType,
    );
    if (!mounted) return;
    setState(() => _categories = categories);
    await _search();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    final results = await widget.knowledge.search(
      _searchController.text,
      missionType: widget.missionType,
      category: _category,
      element: widget.element,
    );
    if (!mounted) return;
    setState(() {
      _results = results.take(30).toList(growable: false);
      _loading = false;
      if (_selectedTerm != null && !_results.contains(_selectedTerm)) {
        _selectedTerm = null;
        _sentenceController.clear();
      }
    });
  }

  void _selectTerm(TechnicalKnowledgeTerm term) {
    setState(() {
      _selectedTerm = term;
      _sentenceController.text = term.sentenceTemplates.isEmpty
          ? term.label
          : OfflineInspectionAiService.buildSentence(
              term.sentenceTemplates.first,
              element: widget.element,
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aide au vocabulaire'),
      content: SizedBox(
        width: 720,
        height: 560,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('vocabulary-search'),
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Terme courant ou défaut observé',
                      hintText: 'Ex. coin cassé, mur gonflé…',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: _category,
                  hint: const Text('Toutes les catégories'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Toutes les catégories'),
                    ),
                    ..._categories.map(
                      (category) => DropdownMenuItem<String?>(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _category = value);
                    _search();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _results.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Aucun terme local correspondant.',
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _results.length,
                                  itemBuilder: (context, index) {
                                    final term = _results[index];
                                    return ListTile(
                                      selected: term == _selectedTerm,
                                      title: Text(term.label),
                                      subtitle: Text(term.category),
                                      onTap: () => _selectTerm(term),
                                    );
                                  },
                                ),
                        ),
                        const VerticalDivider(width: 24),
                        Expanded(
                          flex: 3,
                          child: _selectedTerm == null
                              ? const Center(
                                  child: Text(
                                    'Sélectionnez un terme pour voir sa définition et préparer une phrase.',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _buildTermDetails(_selectedTerm!),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          key: const Key('insert-vocabulary'),
          onPressed: _sentenceController.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, _sentenceController.text.trim()),
          icon: const Icon(Icons.add),
          label: const Text('Insérer'),
        ),
      ],
    );
  }

  Widget _buildTermDetails(TechnicalKnowledgeTerm term) {
    return ListView(
      children: [
        Text(term.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(term.definition),
        if (term.synonyms.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Termes courants : ${term.synonyms.join(', ')}'),
        ],
        const SizedBox(height: 18),
        const Text(
          'Formulation proposée (modifiable)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('vocabulary-sentence'),
          controller: _sentenceController,
          minLines: 3,
          maxLines: 6,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        if (term.sentenceTemplates.length > 1) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _sentenceController.text =
                    OfflineInspectionAiService.buildSentence(
                      term.sentenceTemplates[1],
                      element: widget.element,
                    );
              });
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Utiliser l’autre formulation'),
          ),
        ],
      ],
    );
  }
}

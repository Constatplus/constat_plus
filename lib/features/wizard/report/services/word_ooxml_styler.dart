/// Post-traitement optionnel du document Word.
///
/// La modification directe de l'archive OOXML pouvait produire des fichiers
/// que Microsoft Word considérait comme endommagés. Le générateur docx_dart
/// produit déjà un document valide : cette étape reste volontairement neutre
/// tant qu'un stylage OOXML sûr n'est pas réintroduit.
class WordOoxmlStyler {
  Future<void> apply({
    required String path,
    required Set<String> roomTitles,
  }) async {
    // Ne pas réécrire l'archive .docx : cela préserve sa validité.
  }
}

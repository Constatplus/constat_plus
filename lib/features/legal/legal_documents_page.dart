import 'package:flutter/material.dart';

enum LegalDocumentType { termsOfUse, termsOfSale }

class LegalDocumentsPage extends StatelessWidget {
  const LegalDocumentsPage({
    super.key,
    this.initialDocument = LegalDocumentType.termsOfSale,
  });

  final LegalDocumentType initialDocument;

  @override
  Widget build(BuildContext context) {
    final initialIndex = initialDocument == LegalDocumentType.termsOfUse ? 0 : 1;

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FA),
        appBar: AppBar(
          title: const Text('Conditions générales'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Utilisation'),
              Tab(text: 'Vente'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LegalDocumentView(document: _termsOfUse),
            _LegalDocumentView(document: _termsOfSale),
          ],
        ),
      ),
    );
  }
}

class _LegalDocumentView extends StatelessWidget {
  const _LegalDocumentView({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 920),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F0F172A),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version du 20 juillet 2026',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                ),
                const SizedBox(height: 20),
                const _CompanyCard(),
                const SizedBox(height: 24),
                ...document.sections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          section.body,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.55,
                                color: const Color(0xFF334155),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 40),
                Text(
                  'Ces textes constituent une base de travail destinée à être relue et validée par un conseil juridique avant la commercialisation définitive de Constat+.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'Éditeur : Gaudium Immo SRL\n'
        'Siège social : 19 Avenue du Pont Rouge, 7000 Mons, Belgique\n'
        'BCE / TVA : BE 0786.702.365\n'
        'E-mail : info@gaudiumimmo.be\n'
        'Téléphone : 0478 22 84 77',
        style: TextStyle(height: 1.5, color: Color(0xFF334155)),
      ),
    );
  }
}

class LegalDocument {
  const LegalDocument({required this.title, required this.sections});

  final String title;
  final List<LegalSection> sections;
}

class LegalSection {
  const LegalSection(this.title, this.body);

  final String title;
  final String body;
}

const _termsOfUse = LegalDocument(
  title: 'Conditions Générales d’Utilisation de Constat+',
  sections: [
    LegalSection(
      '1. Objet',
      'Les présentes Conditions Générales d’Utilisation encadrent l’accès et l’utilisation du logiciel Constat+, de ses applications, de ses services en ligne, de ses fonctions de sauvegarde, d’analyse assistée et de génération de rapports. Toute utilisation implique l’acceptation des présentes conditions.',
    ),
    LegalSection(
      '2. Compte utilisateur',
      'L’utilisateur fournit des informations exactes, complètes et actualisées. Il protège ses identifiants et demeure responsable de toute activité effectuée depuis son compte. Il informe sans délai Gaudium Immo SRL en cas d’accès non autorisé ou de suspicion de compromission.',
    ),
    LegalSection(
      '3. Usage professionnel et conformité',
      'L’utilisateur utilise Constat+ conformément aux lois applicables, aux règles professionnelles et aux droits des personnes concernées. Il lui appartient notamment de disposer d’une base juridique valable pour encoder les coordonnées, photographies, signatures et autres données relatives aux propriétaires, locataires, occupants ou tiers.',
    ),
    LegalSection(
      '4. Intelligence artificielle et assistance à la rédaction',
      'Les fonctions d’intelligence artificielle fournissent une aide à l’analyse et à la rédaction. Elles peuvent produire des résultats incomplets ou inexacts. Elles ne remplacent jamais les constatations de l’utilisateur, son jugement professionnel ni les vérifications nécessaires. L’utilisateur contrôle, corrige et valide chaque contenu avant signature, export ou transmission.',
    ),
    LegalSection(
      '5. Photographies et documents',
      'L’utilisateur s’assure qu’il est autorisé à photographier les lieux et à traiter les documents importés. Il évite de collecter des données sans lien avec la mission. Il demeure responsable du classement, de la conservation et de la transmission des rapports et pièces générés.',
    ),
    LegalSection(
      '6. Sauvegarde et fonctionnement hors connexion',
      'Certaines fonctions peuvent être accessibles hors connexion. La synchronisation, les analyses en ligne, les achats et la génération définitive de certains documents peuvent nécessiter une connexion internet. L’utilisateur veille à synchroniser ses dossiers et à conserver les copies utiles de ses rapports définitifs.',
    ),
    LegalSection(
      '7. Disponibilité et maintenance',
      'Gaudium Immo SRL met en œuvre des moyens raisonnables pour assurer la disponibilité de Constat+. Des interruptions peuvent toutefois intervenir pour maintenance, mise à jour, sécurité, panne d’un prestataire ou cas de force majeure. Aucune disponibilité permanente et sans erreur n’est garantie.',
    ),
    LegalSection(
      '8. Utilisations interdites',
      'Il est interdit de contourner les limites d’accès, de tenter d’extraire le code source, de perturber le service, de transmettre des contenus illicites, de revendre un accès sans autorisation ou d’utiliser Constat+ pour porter atteinte aux droits d’autrui.',
    ),
    LegalSection(
      '9. Propriété intellectuelle',
      'Constat+, sa marque, son interface, ses composants, ses modèles et son code restent la propriété de Gaudium Immo SRL ou de ses concédants. L’abonnement accorde uniquement un droit personnel, limité, non exclusif et non transférable d’utilisation pendant sa durée.',
    ),
    LegalSection(
      '10. Responsabilité',
      'L’utilisateur demeure seul responsable des constatations, montants, qualifications, signatures, conclusions et rapports qu’il valide. Dans les limites autorisées par la loi, Gaudium Immo SRL ne répond pas des dommages indirects, pertes d’exploitation, pertes de données imputables à l’utilisateur ou décisions prises sur la seule base d’une suggestion automatisée.',
    ),
    LegalSection(
      '11. Suspension ou fermeture',
      'Un accès peut être suspendu en cas d’impayé, de fraude, de risque de sécurité, d’utilisation abusive ou de violation grave des présentes conditions. Lorsque la situation le permet, l’utilisateur est invité à régulariser avant une fermeture définitive.',
    ),
    LegalSection(
      '12. Droit applicable',
      'Les présentes conditions sont soumises au droit belge. Les règles impératives de protection du consommateur restent applicables. Les parties privilégient une résolution amiable avant toute procédure judiciaire.',
    ),
  ],
);

const _termsOfSale = LegalDocument(
  title: 'Conditions Générales de Vente de Constat+',
  sections: [
    LegalSection(
      '1. Champ d’application',
      'Les présentes Conditions Générales de Vente régissent l’achat d’une mission unique et la souscription aux abonnements Constat+ proposés par Gaudium Immo SRL. Elles complètent les Conditions Générales d’Utilisation.',
    ),
    LegalSection(
      '2. Offres',
      'Les offres disponibles sont présentées dans l’application au moment de la commande. À titre indicatif : Mission unique à 69 €, Solo à 99 € par mois et Pro à 198 € par mois. Les fonctionnalités, quotas d’états des lieux, analyses IA, utilisateurs et plateformes sont précisés avant paiement et prévalent sur toute présentation antérieure.',
    ),
    LegalSection(
      '3. Prix et taxes',
      'Les prix sont indiqués en euros. Le caractère TVAC ou hors TVA est précisé avant la validation de la commande. Le prix applicable est celui affiché au moment de l’achat. Toute modification future d’un abonnement est communiquée avant son entrée en vigueur conformément aux règles applicables.',
    ),
    LegalSection(
      '4. Commande',
      'La commande devient définitive après confirmation du prix, acceptation des conditions, validation du moyen de paiement et confirmation par le prestataire de paiement. Une confirmation est mise à disposition sur un support durable, notamment par e-mail ou dans le compte utilisateur.',
    ),
    LegalSection(
      '5. Paiement',
      'Selon la plateforme, le paiement peut être traité par Stripe, Google Play ou Apple. Les moyens proposés peuvent inclure Bancontact, Visa, Mastercard, Apple Pay et Google Pay. Gaudium Immo SRL ne conserve pas les données complètes de carte bancaire. Les conditions du prestataire de paiement ou de la boutique d’applications s’appliquent également.',
    ),
    LegalSection(
      '6. Abonnements et renouvellement',
      'Les abonnements sont conclus pour la période affichée et renouvelés automatiquement, sauf résiliation avant la date de renouvellement. L’utilisateur peut résilier depuis son compte ou depuis la boutique utilisée pour l’achat. La résiliation prend effet à la fin de la période déjà payée, sauf règle impérative ou politique plus favorable de la plateforme.',
    ),
    LegalSection(
      '7. Mission unique et consommation',
      'Une mission unique donne accès au quota annoncé lors de l’achat. Sauf indication contraire dans l’offre, elle est considérée comme consommée lors de la génération du rapport définitif. La création ou la modification d’un brouillon n’entraîne pas à elle seule la consommation de la mission.',
    ),
    LegalSection(
      '8. Quotas',
      'Les quotas d’états des lieux, d’analyses IA ou d’utilisateurs sont ceux indiqués dans l’offre. Les quotas mensuels non utilisés ne sont pas reportés, sauf mention expresse. Une utilisation anormale, automatisée ou destinée à contourner les limites peut entraîner une restriction temporaire.',
    ),
    LegalSection(
      '9. Droit de rétractation des consommateurs',
      'Lorsqu’un client agit comme consommateur et conclut à distance, il bénéficie en principe d’un délai légal de quatorze jours. Lorsque l’exécution immédiate d’un service ou la fourniture d’un contenu numérique est demandée avant la fin de ce délai, les conséquences sur le droit de rétractation sont présentées séparément et requièrent, lorsque la loi l’exige, un consentement exprès et la reconnaissance de la perte du droit concerné. Cette règle ne limite pas les droits impératifs du consommateur.',
    ),
    LegalSection(
      '10. Remboursements',
      'Les demandes sont examinées selon la loi, la nature de l’achat et les règles du prestataire. Une mission unique non consommée peut faire l’objet d’un remboursement lorsqu’un droit légal existe ou qu’un geste commercial est accordé. Un abonnement résilié reste accessible jusqu’à la fin de la période payée et n’est pas remboursé au prorata, sauf obligation légale ou décision contraire de Gaudium Immo SRL. Les achats Apple ou Google peuvent devoir être réclamés directement auprès de la boutique concernée.',
    ),
    LegalSection(
      '11. Échec de paiement',
      'En cas d’échec, de rejet ou de rétrofacturation, l’accès aux fonctions payantes peut être suspendu. L’utilisateur reste redevable des montants valablement dus et peut régulariser son moyen de paiement depuis la plateforme concernée.',
    ),
    LegalSection(
      '12. Évolution du service',
      'Constat+ peut évoluer afin d’améliorer la sécurité, la conformité ou les fonctionnalités. Une modification substantielle défavorable d’un abonnement en cours fait l’objet d’une information préalable raisonnable et des droits prévus par la loi.',
    ),
    LegalSection(
      '13. Réclamations',
      'Toute réclamation peut être adressée à info@gaudiumimmo.be avec l’adresse du compte, la date de l’achat et la référence de paiement. Les parties cherchent une solution amiable. Le consommateur peut également recourir aux mécanismes de médiation compétents.',
    ),
    LegalSection(
      '14. Droit applicable et juridiction',
      'Les présentes conditions sont soumises au droit belge, sans priver le consommateur des protections impératives de son pays de résidence. Pour les clients professionnels, les juridictions de l’arrondissement judiciaire du siège de Gaudium Immo SRL sont compétentes, sous réserve d’une convention contraire.',
    ),
  ],
);

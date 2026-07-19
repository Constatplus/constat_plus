import 'package:flutter/material.dart';

import 'step_signatures.dart';

class StepExitClosure extends StatelessWidget {
  StepExitClosure({super.key});

  final SignaturesData _signatures = SignaturesData();

  static const String legalText = '''Les parties reconnaissent que la mission de l’expert est terminée. Elles déclarent avoir pris connaissance des observations, des relevés, des clés remises et, le cas échéant, des montants proposés. Le rapport peut être clôturé même en cas de réserve, de refus ou d’absence de signature d’une partie, ces circonstances étant alors mentionnées au procès-verbal.

Nature et valeur juridique du document
Le présent procès-verbal est destiné à constater contradictoirement l’état matériel du bien à la sortie du preneur. Il constitue un élément de preuve entre les parties pour les constatations qui y figurent.

Portée du rapport et impartialité de l’expert
L’expert agit en toute indépendance, neutralité et impartialité. Le document reflète les éléments visibles et accessibles observés lors de la visite, sous réserve de vices cachés, d’éléments dissimulés ou non accessibles.

Réserves et limites de responsabilité
Le rapport ne constitue pas une expertise technique approfondie ni un contrôle de conformité des installations. Les évaluations de remise en état et indemnités ont une valeur estimative et peuvent faire l’objet d’un accord ultérieur, d’un devis ou d’une expertise complémentaire.

Garanties et libération de la caution
La signature atteste que les parties ont été informées du montant proposé et des conditions envisagées pour la libération de la garantie locative, sous réserve de l’accord de toutes les parties et des organismes concernés.

Protection des données
Les données recueillies sont utilisées uniquement pour l’exécution de la mission, la rédaction, la conservation et la transmission du rapport. Les personnes concernées peuvent exercer leurs droits conformément au Règlement général sur la protection des données.

Force probante
Le procès-verbal signé, y compris par signature électronique, peut être produit en justice. L’absence de signature d’une partie n’efface pas les constatations matérielles réalisées par l’expert, mais sa portée contradictoire sera appréciée selon les circonstances.''';

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const Text('Clôture du rapport', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Relisez les mentions de clôture et invitez les parties à signer.', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
      const SizedBox(height: 22),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))), child: const SelectableText(legalText, style: TextStyle(height: 1.55))),
      const SizedBox(height: 24),
      StepSignatures(data: _signatures, includeExpert: true, embedded: true),
    ]);
  }
}

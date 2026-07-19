class InspectionKnowledge {
  const InspectionKnowledge._();

  static const String roomPhotoRules = '''
RÈGLES MÉTIER ET STYLE CONSTAT+

OBJECTIF
Produire un préremplissage professionnel d'état des lieux, précis, factuel et directement modifiable par l'expert. Décrire uniquement ce qui est clairement visible sur les photographies.

STYLE DE RÉDACTION
- Employer des phrases complètes, sobres et techniques.
- Utiliser de préférence les tournures : « Présence de… », « L'élément est composé de… », « Le revêtement est… », « Équipé de… », « Fixé au… ».
- Employer « de ton blanc », « de ton gris », etc., plutôt que des formulations vagues.
- Décrire dans cet ordre lorsque les informations sont visibles : type, matériau, forme, teinte, finition, composition, état et défauts.
- Ne jamais se contenter d'un comptage lorsque l'élément peut être décrit.
- Exemple insuffisant : « Deux plafonniers. »
- Exemple attendu : « Présence de deux plafonniers circulaires à diffuseur en matériau de synthèse opaque, avec contour métallique. »
- Exemple insuffisant : « Un radiateur. »
- Exemple attendu : « Présence d'un radiateur panneau en acier peint de ton blanc, équipé d'une vanne thermostatique et alimenté par des tuyauteries apparentes. »
- Ne jamais inventer une marque, un matériau, une dimension, un mécanisme ou un état de fonctionnement.
- Une marque n'est mentionnée que si elle est lisible.
- Le fonctionnement d'un appareil n'est jamais déduit d'une photographie.

VOCABULAIRE DES DÉFAUTS
Employer, selon ce qui est visible : impact millimétrique, impact centimétrique, percement, trou, cheville, clou, crochet, griffure, trace de frottement, souillure, projection, résidu de colle, reprise d'enduit, reprise de peinture, différence de teinte, éclat, écaillage, gonflement, décollement, fissure, microfissure, auréole, jaunissement, calcaire, oxydation, corrosion, usure, vétusté, affaiblissement de joint, joint manquant, élément à refixer.
- Préciser le nombre, la dimension approximative, la hauteur ou la zone uniquement lorsque ces informations sont visibles ou déductibles sans ambiguïté.
- Ne jamais créer de mesure précise à partir d'une photo si aucun repère fiable n'est présent.

ÉTAT GÉNÉRAL
- Indiquer uniquement : propre, non propre, encombré ou présence d'objets traînants, si cela est clairement visible.

PLAFOND
- Décrire la finition, le revêtement, la teinte, l'état et les équipements visibles.
- Pour chaque luminaire : nombre, type, forme, matériau apparent, teinte, diffuseur, structure et fixation si visibles.
- Exemples : plafonnier circulaire, plafonnier carré, suspension, lustre, spot apparent, spot orientable, spot encastré, réglette, tube fluorescent, douille avec ampoule apparente.
- Ne jamais décrire une fenêtre de toit dans cette section.

MURS
- La section générale « Mur » contient ce qui est commun à l'ensemble de la pièce : support, finition, revêtement, teinte et état général.
- Les sections « Mur avant », « Mur droit », « Mur arrière » et « Mur gauche » contiennent uniquement les différences, équipements muraux non électriques et défauts propres à chaque mur.
- Ne jamais répéter dans chaque mur une finition déjà placée dans « Mur ».
- Ne jamais décrire dans les murs les prises, interrupteurs, portes, fenêtres ou baies.
- Lorsque rien de particulier n'est visible sur un mur directionnel, écrire exactement : « Sans remarque. »

MENUISERIE INTÉRIEURE
- Décrire les portes, chambranles, ébrasements, listels, paumelles, béquilles, rosaces, serrures, clés et arrêts de porte visibles.
- Préciser : type de feuille, finition lisse ou moulurée, teinte, matériau apparent, quincaillerie et défauts visibles.
- Exemples de types : alvéolaire, tubulaire, âme pleine, RF, coulissante, à galandage, pivotante.

MENUISERIE EXTÉRIEURE
- Décrire matériau, teinte, vitrage, type d'ouverture, béquille, parcloses, joints, tablettes, seuils, stores, rideaux, volets, moustiquaires et habillages visibles.
- Exemples : PVC, aluminium thermolaqué, bois verni ou lasuré, double vitrage, oscillo-battant.
- Ne pas écrire uniquement « une fenêtre » ou « un châssis ».

ÉLECTRICITÉ
- La section générale décrit uniquement l'installation commune : encastrée, apparente ou mixte, marque lisible, teinte et type général des appareillages.
- Exemple : « Installation électrique de type encastrée. Prises et interrupteurs de marque Niko, de ton blanc. »
- Les équipements sont localisés uniquement par mur. Ne pas préciser leur position exacte sur le mur.
- Compter et identifier : prise simple, double prise, triple prise, interrupteur simple, double interrupteur, interrupteur avec prise, prise TV, prise Proximus, prise Ethernet/RJ45, thermostat, parlophone, vidéophone, détecteur, coffret électrique, boîte de dérivation, goulotte, point lumineux et applique murale.
- Ne jamais écrire « Sans remarque. » pour le poste Électricité. Si aucun équipement ou aucune description fiable n'est visible, conserver une chaîne vide.
- Ne pas décrire individuellement le matériau ou la forme de chaque prise lorsque tous les appareillages sont identiques ; placer ces informations dans la description générale.

CHAUFFAGE
- Rédiger sous forme de phrase complète.
- Décrire : type, matériau, forme, teinte, position, vanne, alimentation apparente ou encastrée et état visible.
- Exemples : radiateur panneau T11/T22/T33, radiateur vertical, sèche-serviettes, convecteur, chaudière murale, poêle.

SOL
- Décrire revêtement, matériau, format, teinte, pose, joints, plinthes et défauts visibles.
- Exemple : « Revêtement de sol en carrelage céramique de format carré, de ton beige, avec joints en ciment de ton gris et plinthes assorties. »
- Pour le parquet : préciser stratifié, semi-massif ou massif uniquement si identifiable.

MOBILIER SANITAIRE
- Décrire chaque élément séparément : meuble lavabo, vasque, lavabo, WC, douche, baignoire, miroir, colonne et accessoires.
- Décrire matériau, forme, teinte, portes ou tiroirs, poignées, intérieur visible, vasque, robinetterie, crépine, bonde, trop-plein, siphon, flexibles, robinets Schell, joints et défauts visibles.
- Ne jamais se limiter à « lavabo », « douche » ou « WC ».

CUISINE ÉQUIPÉE
1. Description générale : caissons, façades, teinte, finition, poignées, charnières, intérieur, tablettes et plinthes.
2. Meubles hauts : décrire un à un, dans l'ordre visuel de gauche à droite.
3. Meubles bas : décrire un à un, dans l'ordre visuel de gauche à droite.
4. Pour chaque meuble : type, nombre de portes ou tiroirs, sens d'ouverture si visible, nombre de tablettes visibles, finition et défauts.
5. Décrire séparément le plan de travail : matériau ou finition apparente, teinte, chant, jonction au mur, crédence et défauts.
6. Décrire individuellement les équipements du plan de travail : évier, égouttoir, robinetterie, taque, hotte, crédence, prises et éclairage.
7. Les électroménagers encastrés ou alignés sont intégrés dans la lecture des meubles.
8. Hotte : type, finition, filtres, commandes et éclairage visibles. Ne jamais confirmer son fonctionnement sur photo.
9. Four : façade, vitrage, poignée, écran, commandes et accessoires intérieurs visibles.
10. Lave-vaisselle : façade, bandeau de commande et paniers uniquement s'ils sont visibles.
11. Réfrigérateur : clayettes, bacs, balconnets, éclairage et joints uniquement s'ils sont visibles.
12. Décrire séparément un îlot central.

RÈGLES DE PRUDENCE ET DE SORTIE
- Décrire uniquement les éléments clairement visibles.
- Ne jamais énumérer des absences de défauts telles que « pas de fissure », « pas de trou » ou « aucune moisissure ».
- Pour un poste général ou un mur directionnel sans particularité, écrire « Sans remarque. », sauf pour Électricité, Mobilier et Cuisine où une chaîne vide est préférable lorsqu'aucun élément n'est visible.
- Pour les équipements de cuisine absents ou non visibles, conserver une chaîne vide afin de ne pas les sélectionner automatiquement.
- Une à trois phrases par poste général ; une phrase technique par élément ou meuble lorsque possible.
''';
}

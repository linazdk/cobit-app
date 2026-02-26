// lib/models/gap_template.dart

/// Modèle de template d'écart.
/// Un template = un type d'écart récurrent, avec un titre, une action type
/// (si tu veux l'utiliser plus tard) et une criticité par défaut.
class GapTemplate {
  final String label; // Libellé court pour menus / listes
  final String title; // Titre complet de l’écart
  final String
  defaultAction; // Action corrective type (optionnelle pour l’instant)
  final int defaultSeverity; // 0 = mineur, 1 = majeur, 2 = critique

  const GapTemplate({
    required this.label,
    required this.title,
    required this.defaultAction,
    required this.defaultSeverity,
  });
}

/// Quelques templates COBIT d'exemple.
/// Tu peux les adapter/compléter à volonté.
const List<GapTemplate> cobitGapTemplates = [
  GapTemplate(
    label: "Alignement IT",
    title: "Objectifs IT non alignés avec les objectifs stratégiques",
    defaultAction:
        "Aligner les objectifs IT sur la stratégie métier et formaliser cette correspondance.",
    defaultSeverity: 2,
  ),
  GapTemplate(
    label: "Gouvernance des risques",
    title: "Absence de gouvernance des risques IT",
    defaultAction:
        "Mettre en place un processus formalisé de gestion des risques IT avec revue périodique.",
    defaultSeverity: 2,
  ),
  GapTemplate(
    label: "Politiques de sécurité",
    title: "Politiques de sécurité incomplètes ou obsolètes",
    defaultAction:
        "Mettre à jour et approuver les politiques de sécurité couvrant les systèmes critiques.",
    defaultSeverity: 1,
  ),
  GapTemplate(
    label: "Feuille de route IT",
    title: "Absence de feuille de route stratégique IT",
    defaultAction:
        "Définir une feuille de route IT alignée sur la stratégie de l’organisation.",
    defaultSeverity: 1,
  ),
  GapTemplate(
    label: "Registre des risques",
    title: "Registre des risques IT non mis à jour",
    defaultAction:
        "Actualiser le registre des risques IT et planifier une revue régulière.",
    defaultSeverity: 1,
  ),
  GapTemplate(
    label: "Plan de continuité",
    title:
        "Absence de plan de continuité d’activité pour les systèmes critiques",
    defaultAction:
        "Élaborer, tester et documenter un plan de continuité pour les systèmes critiques.",
    defaultSeverity: 2,
  ),
];

/// Mapping question COBIT -> index dans [cobitGapTemplates].
/// Les clés doivent correspondre à tes Answer.questionId (ex: "EDM01.01").
const Map<String, int> questionCobitIdToTemplateIndex = {
  // questionId COBIT -> index dans cobitGapTemplates
  'EDM01.01': 0, // Alignement IT
  'APO12.01': 1, // Gouvernance des risques
  'APO13.01': 2, // Politiques de sécurité
  'APO02.01': 3, // Feuille de route IT
  'APO12.02': 4, // Registre des risques
  'DSS04.01': 5, // Plan de continuité
  // Ajoute ici tes vraies clés COBIT
};

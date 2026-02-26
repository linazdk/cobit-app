import '../models/cobit_models.dart';

/// Parse le champ scope de l’audit (ex: "APO05,DSS03,EDM01")
/// et renvoie un Set<String> contenant les ids d’objectifs COBIT.
Set<String> parseScopeToObjectiveIds(String? scope) {
  if (scope == null || scope.trim().isEmpty) {
    return {};
  }
  return scope
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet();
}

/// Convertit un Set<String> d’ids d’objectifs (APO05, DSS03...)
/// en string pour Audit.scope : "APO05,DSS03"
String objectiveIdsToScopeString(Set<String> ids) {
  if (ids.isEmpty) return '';
  return ids.join(',');
}

/// Utilitaire pratique : filtrer les objectifs en fonction du scope.
/// Si le scope est vide -> renvoie tous les objectifs.
List<CobitObjective> filterObjectivesByScope(
  List<CobitObjective> all,
  String? scope,
) {
  final ids = parseScopeToObjectiveIds(scope);
  if (ids.isEmpty) return all;
  return all.where((obj) => ids.contains(obj.id)).toList();
}

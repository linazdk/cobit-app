// lib/models/cobit_practice_models.dart

/// Pratique de management COBIT (EDM01.01, APO13.02, etc.)
class CobitManagementPractice {
  final String id; // ex: "EDM01.01"
  final String objectiveId; // ex: "EDM01"
  final String name;
  final String description;

  CobitManagementPractice({
    required this.id,
    required this.objectiveId,
    required this.name,
    required this.description,
  });

  /// Chargement depuis SQLite (table cobit_practices)
  factory CobitManagementPractice.fromMap(Map<String, dynamic> map) {
    return CobitManagementPractice(
      id: map['id'] as String,
      objectiveId: (map['objectiveId'] ?? map['objectiveCode']) as String,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

  /// Pour insertion / update en base
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'objectiveId': objectiveId,
      'name': name,
      'description': description,
    };
  }
}

/// Activité détaillée rattachée à une pratique (EDM01.01-A1, etc.)
class CobitActivity {
  final String id; // ex: "EDM01.01-A1"
  final String description; // texte de l'activité
  final String practiceId; // ex: "EDM01.01"

  CobitActivity({
    required this.id,
    required this.description,
    required this.practiceId,
  });

  /// Chargement depuis JSON (référentiel)
  factory CobitActivity.fromJson(
    Map<String, dynamic> json, {
    required String practiceId,
  }) {
    return CobitActivity(
      id: json['id'] as String,
      description: json['description'] as String? ?? '',
      practiceId: practiceId,
    );
  }

  /// Chargement depuis SQLite (table cobit_activities)
  factory CobitActivity.fromMap(Map<String, dynamic> map) {
    return CobitActivity(
      id: map['id'] as String,
      description: map['description'] as String? ?? '',
      practiceId: map['practiceId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'description': description, 'practiceId': practiceId};
  }
}

/// Structure utilisée uniquement pour charger un bloc d’activités
/// d’un même practiceId depuis le JSON (si tu veux t’en servir).
class CobitPracticeActivities {
  final String practiceId; // ex: "EDM01.01"
  final List<CobitActivity> activities;

  CobitPracticeActivities({required this.practiceId, required this.activities});

  factory CobitPracticeActivities.fromJson(Map<String, dynamic> json) {
    final pid = json['practiceId'] as String;
    return CobitPracticeActivities(
      practiceId: pid,
      activities: (json['activities'] as List<dynamic>)
          .map(
            (e) => CobitActivity.fromJson(
              e as Map<String, dynamic>,
              practiceId: pid,
            ),
          )
          .toList(),
    );
  }
}

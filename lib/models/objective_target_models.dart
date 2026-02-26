class ObjectiveTarget {
  final int? id;
  final int auditId;
  final String objectiveId; // ex: "APO05"
  final int targetLevel; // 0–5

  ObjectiveTarget({
    this.id,
    required this.auditId,
    required this.objectiveId,
    required this.targetLevel,
  });

  ObjectiveTarget copyWith({
    int? id,
    int? auditId,
    String? objectiveId,
    int? targetLevel,
  }) {
    return ObjectiveTarget(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      objectiveId: objectiveId ?? this.objectiveId,
      targetLevel: targetLevel ?? this.targetLevel,
    );
  }

  factory ObjectiveTarget.fromMap(Map<String, dynamic> map) {
    return ObjectiveTarget(
      id: map['id'] as int?,
      auditId: map['audit_id'] as int,
      objectiveId: map['objective_id'] as String,
      targetLevel: map['target_level'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audit_id': auditId,
      'objective_id': objectiveId,
      'target_level': targetLevel,
    };
  }
}

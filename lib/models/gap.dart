// lib/models/gap_models.dart

class Gap {
  final int? id; // null avant insertion, auto-incrément après
  final int auditId; // FK vers Audit.id
  final String title;
  final String? description;
  final int severity; // 0 = mineur, 1 = majeur, 2 = critique
  final int
  status; // 0 = détecté, 1 = validé, 2 = planifié, 3 = en cours, 4 = clos
  final String? owner;
  final DateTime detectedAt;
  final DateTime? targetCloseDate;
  final DateTime? closedAt;
  final double progress; // 0.0 → 1.0

  Gap({
    this.id,
    required this.auditId,
    required this.title,
    this.description,
    this.severity = 0,
    this.status = 0,
    this.owner,
    required this.detectedAt,
    this.targetCloseDate,
    this.closedAt,
    this.progress = 0.0,
  });

  Gap copyWith({
    int? id,
    int? auditId,
    String? title,
    String? description,
    int? severity,
    int? status,
    String? owner,
    DateTime? detectedAt,
    DateTime? targetCloseDate,
    DateTime? closedAt,
    double? progress,
  }) {
    return Gap(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      detectedAt: detectedAt ?? this.detectedAt,
      targetCloseDate: targetCloseDate ?? this.targetCloseDate,
      closedAt: closedAt ?? this.closedAt,
      progress: progress ?? this.progress,
    );
  }

  factory Gap.fromMap(Map<String, dynamic> map) {
    return Gap(
      id: map['id'] as int?,
      auditId: map['audit_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      severity: map['severity'] as int,
      status: map['status'] as int,
      owner: map['owner'] as String?,
      detectedAt: DateTime.parse(map['detected_at'] as String),
      targetCloseDate: map['target_close_date'] != null
          ? DateTime.parse(map['target_close_date'] as String)
          : null,
      closedAt: map['closed_at'] != null
          ? DateTime.parse(map['closed_at'] as String)
          : null,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audit_id': auditId,
      'title': title,
      'description': description,
      'severity': severity,
      'status': status,
      'owner': owner,
      'detected_at': detectedAt.toIso8601String(),
      'target_close_date': targetCloseDate?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'progress': progress,
    };
  }
}

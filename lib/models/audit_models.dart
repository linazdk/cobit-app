class AuditSession {
  final int? id;
  final int organizationId;
  final String label;
  final DateTime date;

  AuditSession({
    this.id,
    required this.organizationId,
    required this.label,
    required this.date,
  });

  AuditSession copyWith({
    int? id,
    int? organizationId,
    String? label,
    DateTime? date,
  }) {
    return AuditSession(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      label: label ?? this.label,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'organization_id': organizationId,
    'label': label,
    'date': date.toIso8601String(),
  };

  factory AuditSession.fromMap(Map<String, dynamic> map) {
    return AuditSession(
      id: map['id'] as int?,
      organizationId: map['organization_id'] as int,
      label: map['label'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}

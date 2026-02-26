import 'package:cobit/workflow/audit_workflow.dart';

/// Organisation
class Organization {
  final int? id; // ⚠️ côté Dart: id
  final String name;
  final String? sector;
  final int? size;

  Organization({this.id, required this.name, this.sector, this.size});

  Organization copyWith({int? id, String? name, String? sector, int? size}) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      sector: sector ?? this.sector,
      size: size ?? this.size,
    );
  }

  /// Map <-> DB: on utilise `organization_id` pour coller à la table SQL
  Map<String, dynamic> toMap() {
    return {
      'organization_id': id,
      'name': name,
      'sector': sector,
      'size': size,
    };
  }

  factory Organization.fromMap(Map<String, dynamic> map) {
    return Organization(
      id: map['organization_id'] as int?,
      name: map['name'] as String,
      sector: map['sector'] as String?,
      size: map['size'] as int?,
    );
  }
}

/// Audit
class Audit {
  final int? id;
  final int organizationId;
  final DateTime date;
  final String? auditorName;
  final String? scope;
  final String status;

  Audit({
    this.id,
    required this.organizationId,
    required this.date,
    this.auditorName,
    this.scope,
    this.status = 'Draft',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization_id': organizationId,
      'date': date.toIso8601String(),
      'auditor_name': auditorName,
      'scope': scope,
      'status': status,
    };
  }

  factory Audit.fromMap(Map<String, dynamic> map) {
    return Audit(
      id: map['id'] as int?,
      organizationId: map['organization_id'] as int,
      date: DateTime.parse(map['date'] as String),
      auditorName: map['auditor_name'] as String?,
      scope: map['scope'] as String?,
      status: map['status'] as String? ?? 'Brouillon',
    );
  }
}

extension AuditStatusExtension on Audit {
  AuditStatus get statusEnum => auditStatusFromString(status);

  Audit copyWithStatus(AuditStatus newStatus) {
    return Audit(
      id: id,
      organizationId: organizationId,
      date: date,
      auditorName: auditorName,
      scope: scope,
      status: auditStatusToString(newStatus),
    );
  }
}

/// Réponse à une question d’audit
class Answer {
  final int? id;
  final int auditId;
  final String questionId; // <-- String COBIT
  final int maturityLevel; // 0–5
  final String? comment;

  Answer({
    this.id,
    required this.auditId,
    required this.questionId,
    required this.maturityLevel,
    this.comment,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'audit_id': auditId,
    'question_id': questionId,
    'maturity_level': maturityLevel,
    'comment': comment,
  };

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'] as int?,
      auditId: map['audit_id'] as int,
      questionId: map['question_id'] as String,
      maturityLevel: map['maturity_level'] as int,
      comment: map['comment'] as String?,
    );
  }
}

/// Question COBIT stockée en base (table `questions`)
class Question {
  final int? id;
  final int processId;
  final String text;

  Question({this.id, required this.processId, required this.text});

  Map<String, dynamic> toMap() => {
    'id': id,
    'process_id': processId,
    'text': text,
  };

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int?,
      processId: map['process_id'] as int,
      text: map['text'] as String,
    );
  }
}

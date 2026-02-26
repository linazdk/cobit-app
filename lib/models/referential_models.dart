// lib/models/referential_models.dart

/// Domaine COBIT en base (table cobit_domains)
class CobitDomainRef {
  final int? id;
  final String code; // ex: "EDM"
  final String name; // ex: "Evaluate, Direct and Monitor"

  CobitDomainRef({this.id, required this.code, required this.name});

  CobitDomainRef copyWith({int? id, String? code, String? name}) {
    return CobitDomainRef(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  factory CobitDomainRef.fromMap(Map<String, dynamic> map) {
    return CobitDomainRef(
      id: map['id'] as int?,
      code: map['code'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'name': name};
  }
}

/// Objectif / Processus COBIT (table cobit_processes)
class CobitProcessRef {
  final int? id;
  final int domainId; // FK vers cobit_domains.id
  final String code; // ex: "APO05"
  final String name; // ex: "Manage Portfolio"

  CobitProcessRef({
    this.id,
    required this.domainId,
    required this.code,
    required this.name,
  });

  CobitProcessRef copyWith({
    int? id,
    int? domainId,
    String? code,
    String? name,
  }) {
    return CobitProcessRef(
      id: id ?? this.id,
      domainId: domainId ?? this.domainId,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  factory CobitProcessRef.fromMap(Map<String, dynamic> map) {
    return CobitProcessRef(
      id: map['id'] as int?,
      domainId: map['domain_id'] as int,
      code: map['code'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'domain_id': domainId, 'code': code, 'name': name};
  }
}

/// Question COBIT (table questions)
class CobitQuestionRef {
  final int? id;
  final int processId; // FK vers cobit_processes.id
  final String text;

  CobitQuestionRef({this.id, required this.processId, required this.text});

  CobitQuestionRef copyWith({int? id, int? processId, String? text}) {
    return CobitQuestionRef(
      id: id ?? this.id,
      processId: processId ?? this.processId,
      text: text ?? this.text,
    );
  }

  factory CobitQuestionRef.fromMap(Map<String, dynamic> map) {
    return CobitQuestionRef(
      id: map['id'] as int?,
      processId: map['process_id'] as int,
      text: map['text'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'process_id': processId, 'text': text};
  }
}

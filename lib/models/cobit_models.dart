enum CobitDomain { edm, apo, bai, dss, mea }

extension CobitDomainExt on CobitDomain {
  String get code {
    switch (this) {
      case CobitDomain.edm:
        return 'EDM';
      case CobitDomain.apo:
        return 'APO';
      case CobitDomain.bai:
        return 'BAI';
      case CobitDomain.dss:
        return 'DSS';
      case CobitDomain.mea:
        return 'MEA';
    }
  }

  String get label {
    switch (this) {
      case CobitDomain.edm:
        return 'Evaluate, Direct and Monitor';
      case CobitDomain.apo:
        return 'Align, Plan and Organize';
      case CobitDomain.bai:
        return 'Build, Acquire and Implement';
      case CobitDomain.dss:
        return 'Deliver, Service and Support';
      case CobitDomain.mea:
        return 'Monitor, Evaluate and Assess';
    }
  }

  static CobitDomain fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'EDM':
        return CobitDomain.edm;
      case 'APO':
        return CobitDomain.apo;
      case 'BAI':
        return CobitDomain.bai;
      case 'DSS':
        return CobitDomain.dss;
      case 'MEA':
        return CobitDomain.mea;
      default:
        throw ArgumentError('Unknown COBIT domain: $code');
    }
  }
}

class CobitObjective {
  final String id; // e.g. "APO01"
  final String name; // label
  final CobitDomain domain;

  CobitObjective({required this.id, required this.name, required this.domain});

  factory CobitObjective.fromJson(Map<String, dynamic> json) {
    return CobitObjective(
      id: json['id'] as String,
      name: json['name'] as String,
      domain: CobitDomainExt.fromCode(json['domain'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'domain': domain.code,
  };
}

class CobitQuestion {
  final String id; // e.g. "APO01_Q1"
  final String objectiveId; // e.g. "APO01"
  final String text;

  CobitQuestion({
    required this.id,
    required this.objectiveId,
    required this.text,
  });

  factory CobitQuestion.fromJson(Map<String, dynamic> json) {
    return CobitQuestion(
      id: json['id'] as String,
      objectiveId: json['objectiveId'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'objectiveId': objectiveId,
    'text': text,
  };
}

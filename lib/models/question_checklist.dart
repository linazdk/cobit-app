class ChecklistItem {
  final String id; // ex: "APO01_Q1_I1"
  final String text; // libellé à afficher

  ChecklistItem({required this.id, required this.text});

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class QuestionChecklist {
  final String questionId; // ex: "APO01_Q1"
  final List<ChecklistItem> items;

  QuestionChecklist({required this.questionId, required this.items});

  factory QuestionChecklist.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return QuestionChecklist(
      questionId: json['questionId'] as String,
      items: rawItems
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

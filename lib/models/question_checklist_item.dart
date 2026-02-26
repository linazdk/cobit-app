class QuestionChecklistItem {
  final String id;
  final String questionId;
  final String text;

  QuestionChecklistItem({
    required this.id,
    required this.questionId,
    required this.text,
  });

  factory QuestionChecklistItem.fromJson(Map<String, dynamic> json) {
    return QuestionChecklistItem(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      text: json['text'] as String,
    );
  }
}

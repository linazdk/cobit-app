class Question {
  final String? id;
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
      id: map['id'] as String?,
      processId: map['process_id'] as int,
      text: map['text'] as String,
    );
  }
}

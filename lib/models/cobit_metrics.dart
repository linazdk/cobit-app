class CobitObjectiveMetrics {
  final String objectiveId; // ex: "APO13"
  final List<String> metrics;

  CobitObjectiveMetrics({required this.objectiveId, required this.metrics});

  factory CobitObjectiveMetrics.fromMap(Map<String, dynamic> map) {
    final rawList = map['metrics'] as List<dynamic>? ?? [];
    return CobitObjectiveMetrics(
      objectiveId: map['objectiveId'] as String,
      metrics: rawList.map((e) => e.toString()).toList(),
    );
  }
}

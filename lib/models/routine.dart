class Routine {
  final String id;
  final DateTime date;
  final List<String> taskIds;
  final double aiScore;

  Routine({
    required this.id,
    required this.date,
    required this.taskIds,
    this.aiScore = 0.0,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'taskIds': taskIds,
      'aiScore': aiScore,
    };
  }

  // Create from Map (Firestore)
  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      taskIds: List<String>.from(map['taskIds']),
      aiScore: map['aiScore'] ?? 0.0,
    );
  }
}
class Question {
  final String id;
  final String sessionId;
  final String text;
  final DateTime timestamp;
  final String userId;
  final bool isArchived;

  Question({
    required this.id,
    required this.sessionId,
    required this.text,
    required this.timestamp,
    required this.userId,
    this.isArchived = false,
  });

  factory Question.fromMap(String id, Map<dynamic, dynamic> map) {
    return Question(
      id: id,
      sessionId: map['sessionId'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      userId: map['userId'] ?? '',
      isArchived: map['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'userId': userId,
      'isArchived': isArchived,
    };
  }
}

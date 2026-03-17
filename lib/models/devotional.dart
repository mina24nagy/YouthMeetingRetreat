class Devotional {
  final String id;
  final int day;
  final String title;
  final String content;
  final DateTime date;

  Devotional({
    required this.id,
    required this.day,
    required this.title,
    required this.content,
    required this.date,
  });

  factory Devotional.fromMap(String id, Map<dynamic, dynamic> map) {
    return Devotional(
      id: id,
      day: map['day'] ?? 1,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'title': title,
      'content': content,
      'date': date.millisecondsSinceEpoch,
    };
  }
}

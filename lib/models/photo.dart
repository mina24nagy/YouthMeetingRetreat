class Photo {
  final String id;
  final String url;
  final String uploadedBy;
  final DateTime timestamp;

  Photo({
    required this.id,
    required this.url,
    required this.uploadedBy,
    required this.timestamp,
  });

  factory Photo.fromMap(String id, Map<dynamic, dynamic> map) {
    return Photo(
      id: id,
      url: map['url'] ?? '',
      uploadedBy: map['uploadedBy'] ?? 'Anonymous',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'uploadedBy': uploadedBy,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

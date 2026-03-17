class Session {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final List<Resource> resources;

  Session({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.resources = const [],
  });

  factory Session.fromMap(String id, Map<dynamic, dynamic> map) {
    return Session(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] ?? 0),
      location: map['location'] ?? '',
      resources: (map['resources'] as List<dynamic>?)
              ?.map((e) => Resource.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'location': location,
      'resources': resources.map((e) => e.toMap()).toList(),
    };
  }
}

class Resource {
  final String name;
  final String url;
  final String type; // pdf, ppt, word, etc.

  Resource({
    required this.name,
    required this.url,
    required this.type,
  });

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? 'other',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'type': type,
    };
  }
}

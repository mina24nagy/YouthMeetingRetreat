import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/session.dart';
import '../models/question.dart';
import '../models/photo.dart';
import '../models/devotional.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  RealtimeDatabaseService() {
    // Enable persistence for offline support as requested (Not supported on web)
    if (!kIsWeb) {
      _db.setPersistenceEnabled(true);
      _db.setPersistenceCacheSizeBytes(10000000); // 10MB cache
    }
  }

  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('user_id', userId);
    }
    return userId;
  }

  // --- Sessions ---
  Stream<List<Session>> getSessions() {
    return _db.ref('sessions').onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return [];
      
      try {
        if (value is Map) {
          return value.entries.map((e) {
            return Session.fromMap(e.key.toString(), e.value as Map);
          }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
        } else if (value is List) {
          // Firebase sometimes returns a List if keys are sequential integers
          return value
              .asMap()
              .entries
              .where((e) => e.value != null)
              .map((e) => Session.fromMap(e.key.toString(), e.value as Map))
              .toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
        }
      } catch (e) {
        debugPrint('Error parsing sessions: $e');
      }
      return [];
    });
  }

  Future<void> updateSession(Session session) async {
    await _db.ref('sessions/${session.id}').update(session.toMap());
  }

  // --- Q&A ---
  Stream<List<Question>> getQuestions(String sessionId, {String? userId}) {
    return _db
        .ref('questions')
        .orderByChild('sessionId')
        .equalTo(sessionId)
        .onValue
        .map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.entries
          .map((e) => Question.fromMap(e.key.toString(), e.value as Map))
          .where((q) {
            final isNotArchived = !q.isArchived;
            final isUserMatch = userId == null || q.userId == userId;
            return isNotArchived && isUserMatch;
          })
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> submitQuestion(Question question) async {
    await _db.ref('questions').push().set(question.toMap());
  }

  Future<void> archiveQuestion(String questionId) async {
    await _db.ref('questions/$questionId').update({'isArchived': true});
  }

  // --- Devotionals ---
  Stream<List<Devotional>> getDevotionals() {
    return _db.ref('devotionals').onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return [];
      
      if (value is Map) {
        return value.entries.map((e) {
          return Devotional.fromMap(e.key.toString(), e.value as Map);
        }).toList()..sort((a, b) => a.day.compareTo(b.day));
      }
      return [];
    });
  }


  Future<void> addDevotional(Devotional devotional) async {
    await _db.ref('devotionals').push().set(devotional.toMap());
  }

  Future<void> updateDevotional(Devotional devotional) async {
    await _db.ref('devotionals/${devotional.id}').update(devotional.toMap());
  }

  Future<void> deleteDevotional(String id) async {
    await _db.ref('devotionals/$id').remove();
  }

  // --- Gallery ---
  Stream<List<Photo>> getPhotos() {
    return _db.ref('gallery_meta').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.entries.map((e) {
        return Photo.fromMap(e.key.toString(), e.value as Map);
      }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> addPhotoMetadata(Photo photo) async {
    await _db.ref('gallery_meta').push().set(photo.toMap());
  }

  // --- Admin ---
  Future<String?> getAdminSecret() async {
    final snapshot = await _db.ref('admin_config/secret').get();
    return snapshot.value?.toString();
  }

  Future<void> broadcastBroadcastNotification(String message) async {
    await _db.ref('broadcasts').push().set({
      'message': message,
      'timestamp': ServerValue.timestamp,
    });
  }

  Stream<Map<dynamic, dynamic>?> getBroadcastsStream() {
    return _db.ref('broadcasts').limitToLast(1).onChildAdded.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        return value;
      }
      return null;
    });
  }
}
